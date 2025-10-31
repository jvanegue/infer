(*
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 *)

open! IStd
module L = Logging
module StringMap = IString.Map
module StringSet = IString.Set
module IntSet = IInt.Set

(* ===== Type Definitions ===== *)
type ast_node =
  | Dict of ast_node StringMap.t
  | List of ast_node list
  | Str of string
  | Int of int
  | Float of float
  | Bool of bool
  | Null
[@@deriving compare, equal]

type diff = LineAdded of int | LineRemoved of int [@@deriving compare, equal]

(* ===== Constants ===== *)
(* AST field names *)
let type_field_name = "_type"

let field_args = "args"

let field_ctx = "ctx"

let field_end_lineno = "end_lineno"

let field_func = "func"

let field_id = "id"

let field_keywords = "keywords"

let field_lineno = "lineno"

let field_value = "value"

(* Python integration *)
let python_ast_parser_code =
  {|
import ast, json

def node_to_dict(node):
    if isinstance(node, ast.AST):
        result = {"_type": node.__class__.__name__}

        for attr in ("lineno", "end_lineno"):
            if hasattr(node, attr):
                result[attr] = getattr(node, attr)

        for field, value in ast.iter_fields(node):
            result[field] = node_to_dict(value)
        return result
    elif isinstance(node, list):
        return [node_to_dict(x) for x in node]
    elif node is Ellipsis:  # Handle ellipsis
        return "..."
    else:
        return node  # literals: str, int, None, etc.

def parse_to_json(source: str) -> str:
    tree = ast.parse(source)
    return json.dumps(node_to_dict(tree))
  |}


let init () =
  if not (Py.is_initialized ()) then Py.initialize ~interpreter:Version.python_exe () ;
  let main_module = Py.Import.import_module "__main__" in
  ignore (Py.Run.simple_string python_ast_parser_code) ;
  let parse_func = Py.Module.get main_module "parse_to_json" in
  parse_func


(* ===== AST Type Helpers ===== *)
let get_type fields =
  StringMap.find_opt type_field_name fields
  |> Option.value_or_thunk ~default:(fun () -> L.die InternalError "Could not find ast node type")


let is_type fields type_name : bool =
  match get_type fields with Str name -> String.equal name type_name | _ -> false


let is_line_number_field field_name =
  String.equal field_name field_lineno || String.equal field_name field_end_lineno


let is_type_annotation_field field_name =
  String.equal field_name "annotation" || String.equal field_name "returns"


let get_line_number (fields : ast_node StringMap.t) : int option =
  match StringMap.find_opt field_lineno fields with Some (Int l1) -> Some l1 | _ -> None


let get_line_number_of_node = function Dict f -> get_line_number f | _ -> None

(* ===== AST Node Construction ===== *)
module AstNode = struct
  let make_dict_node field_list = Dict (StringMap.of_list field_list)

  let find_field_or_null field_name fields =
    Option.value (StringMap.find_opt field_name fields) ~default:Null


  let rec of_yojson (j : Yojson.Safe.t) : ast_node =
    match j with
    | `Assoc fields ->
        make_dict_node (List.map ~f:(fun (k, v) -> (k, of_yojson v)) fields)
    | `List l ->
        List (List.map ~f:of_yojson l)
    | `String s ->
        Str s
    | `Int i ->
        Int i
    | `Float f ->
        Float f
    | `Bool b ->
        Bool b
    | `Null ->
        Null
    | _ ->
        L.die InternalError "unsupported JSON type"


  let rec to_str ?(indent = 0) (node : ast_node) : string =
    let indent_str = String.make (indent * 2) ' ' in
    let next_indent = indent + 1 in
    let next_indent_str = String.make (next_indent * 2) ' ' in
    match node with
    | Dict fields ->
        "Dict: {"
        ^ StringMap.fold
            (fun k v acc -> acc ^ "\n" ^ next_indent_str ^ k ^ "=" ^ to_str ~indent:next_indent v)
            fields ""
        ^ "\n" ^ indent_str ^ "}"
    | List l ->
        "List: ["
        ^ String.concat ~sep:" "
            (List.map ~f:(fun node -> "\n" ^ next_indent_str ^ to_str ~indent:next_indent node) l)
        ^ "\n" ^ indent_str ^ "]"
    | Str s ->
        "Str: " ^ s
    | Int i ->
        "Int: " ^ Int.to_string i
    | Float f ->
        "Float: " ^ Float.to_string f
    | Bool b ->
        "Bool: " ^ Bool.to_string b
    | Null ->
        "Null"


  let replace_key_in_dict_node fields key new_value = StringMap.add key new_value fields
end

(* ===== AST Normalization ===== *)
module Normalize = struct
  let get_builtin_name_from_type_name type_name =
    match type_name with
    | "Dict" | "FrozenSet" | "List" | "Set" | "Tuple" ->
        Some (String.lowercase type_name)
    | _ ->
        None


  let ann_assign_to_assign fields : ast_node =
    (* remove annotation, simple, type_comment, change type to assign, target becomes targets = [target] *)
    let assign_fields =
      StringMap.fold
        (fun k field_node acc ->
          match k with
          | "annotation" | "simple" ->
              acc
          | k when String.equal k type_field_name ->
              StringMap.add type_field_name (Str "Assign") acc
          | "target" ->
              StringMap.add "targets" (List [field_node]) acc
          | _ ->
              StringMap.add k field_node acc )
        fields StringMap.empty
    in
    Dict (StringMap.add "type_comment" Null assign_fields)


  let get_annotations_node_ignore_case fields1 fields2 =
    let get_id_name_opt value_fields =
      match StringMap.find_opt field_id value_fields with
      | Some (Str name) ->
          get_builtin_name_from_type_name name
      | _ ->
          None
    in
    let update_fields fields value_fields new_name =
      let new_value_fields =
        AstNode.replace_key_in_dict_node value_fields field_id (Str new_name)
      in
      AstNode.replace_key_in_dict_node fields field_value (Dict new_value_fields)
    in
    match (StringMap.find_opt field_value fields1, StringMap.find_opt field_value fields2) with
    | Some (Dict value_fields1), Some (Dict value_fields2) -> (
      match (get_id_name_opt value_fields1, get_id_name_opt value_fields2) with
      | Some name1, None ->
          Some (update_fields fields1 value_fields1 name1, fields2)
      | None, Some name2 ->
          Some (fields1, update_fields fields2 value_fields2 name2)
      | _, _ ->
          None )
    | None, None -> (
      match (StringMap.find_opt field_id fields1, StringMap.find_opt field_id fields2) with
      | Some (Str "Any"), Some (Str "object") ->
          Some (AstNode.replace_key_in_dict_node fields1 field_id (Str "object"), fields2)
      | _, _ ->
          None )
    | _, _ ->
        None


  let rec apply (node : ast_node) : ast_node =
    match node with
    | Dict fields when is_type fields "Import" || is_type fields "ImportFrom" ->
        Null
    | Dict fields when is_type fields "Compare" -> (
        let left_node = StringMap.find_opt "left" fields in
        let left_fields =
          match left_node with Some (Dict fields) -> fields | _ -> StringMap.empty
        in
        match StringMap.find_opt "attr" left_fields with
        | Some (Str "__class__") ->
            let fst_arg =
              match StringMap.find_opt "value" left_fields with
              | Some arg ->
                  arg
              | _ ->
                  L.die InternalError "Could not find object where __class__ attribute is accessed"
            in
            let snd_arg =
              match StringMap.find_opt "comparators" fields with
              | Some (List [x]) ->
                  x
              | _ ->
                  L.die InternalError
                    "Could not find rhs type in comparison using __class__ attribute"
            in
            let ctx_node = AstNode.find_field_or_null field_ctx left_fields in
            let lineno = AstNode.find_field_or_null field_lineno fields in
            let end_lineno = AstNode.find_field_or_null field_end_lineno fields in
            let func_node =
              AstNode.make_dict_node
                [ (type_field_name, Str "Name")
                ; (field_id, Str "isinstance")
                ; (field_ctx, ctx_node)
                ; (field_lineno, lineno)
                ; (field_end_lineno, end_lineno) ]
            in
            AstNode.make_dict_node
              [ (type_field_name, Str "Call")
              ; (field_lineno, lineno)
              ; (field_end_lineno, end_lineno)
              ; (field_func, func_node)
              ; (field_args, List [fst_arg; snd_arg])
              ; (field_keywords, List []) ]
        | _ ->
            Dict (StringMap.map (fun v -> apply v) fields) )
    | Dict fields ->
        Dict (StringMap.map (fun v -> apply v) fields)
    | List l ->
        List
          (List.filter
             ~f:(fun n -> match n with Null -> false | _ -> true)
             (List.map ~f:apply l) )
    | other ->
        other
end

(* ===== Diff Computation ===== *)
module Diff = struct
  let append_removed_line_to_diff_list left_line acc =
    Option.value_map left_line ~default:acc ~f:(fun line -> LineRemoved line :: acc)


  let append_added_line_to_diff_list right_line acc =
    Option.value_map right_line ~default:acc ~f:(fun line -> LineAdded line :: acc)


  let rec get_diff ?(left_line : int option = None) ?(right_line : int option = None)
      (n1 : ast_node) (n2 : ast_node) : diff list =
    match (n1, n2) with
    | a, b when equal_ast_node a b ->
        []
    | Dict f1, Dict f2 ->
        let left_line = get_line_number f1 in
        let right_line = get_line_number f2 in
        if is_type f1 "Assign" && is_type f2 "AnnAssign" then
          get_diff ~left_line ~right_line n1 (Normalize.ann_assign_to_assign f2)
        else
          let diffs =
            StringMap.fold
              (fun k v1 acc ->
                match StringMap.find_opt k f2 with
                | Some v2 when is_type_annotation_field k -> (
                  (* special case for type annotations *)
                  match (v1, v2) with
                  | Null, Dict _ ->
                      acc
                  | Dict fields1, Dict fields2 -> (
                    match Normalize.get_annotations_node_ignore_case fields1 fields2 with
                    | None ->
                        get_diff ~left_line ~right_line v1 v2 @ acc
                    | Some (new_fields1, new_fields2) ->
                        get_diff ~left_line ~right_line (Dict new_fields1) (Dict new_fields2) @ acc
                    )
                  | _ ->
                      get_diff ~left_line ~right_line v1 v2 @ acc )
                | Some _ when is_line_number_field k ->
                    acc
                | Some v2 ->
                    get_diff ~left_line ~right_line v1 v2 @ acc
                | None ->
                    append_removed_line_to_diff_list left_line acc )
              f1 []
          in
          let missing_in_left =
            StringMap.fold
              (fun k _ acc ->
                if StringMap.mem k f1 then acc else append_added_line_to_diff_list right_line acc )
              f2 []
          in
          diffs @ missing_in_left
    | List l1, List l2 ->
        let rec aux acc xs ys =
          match (xs, ys) with
          | x :: xt, y :: yt ->
              aux (get_diff ~left_line ~right_line x y @ acc) xt yt
          | x :: xt, [] ->
              aux (append_removed_line_to_diff_list (get_line_number_of_node x) acc) xt []
          | [], y :: yt ->
              aux (append_added_line_to_diff_list (get_line_number_of_node y) acc) [] yt
          | [], [] ->
              acc
        in
        aux [] l1 l2
    | Dict f1, _ ->
        append_removed_line_to_diff_list (get_line_number f1) []
    | _, Dict f2 ->
        append_added_line_to_diff_list (get_line_number f2) []
    | _ ->
        append_removed_line_to_diff_list left_line [] @ append_added_line_to_diff_list right_line []


  let split_diffs diffs =
    List.fold
      ~f:(fun (lines_removed, lines_added) diff ->
        match diff with
        | LineRemoved line_number ->
            (IntSet.add line_number lines_removed, lines_added)
        | LineAdded line_number ->
            (lines_removed, IntSet.add line_number lines_added) )
      ~init:(IntSet.empty, IntSet.empty) diffs
end

let parse_and_transform parse_func source =
  let parse_func = parse_func |> Py.Callable.to_function in
  let ast = parse_func [|Py.String.of_string source|] |> Py.String.to_string in
  AstNode.of_yojson (Yojson.Safe.from_string ast) |> Normalize.apply


(* ===== Diff Formatting and Output ===== *)
module Output = struct
  let write_output previous_file current_file diffs =
    let out_path = ResultsDir.get_path SemDiff in
    let outcome = if List.is_empty diffs then "equal" else "different" in
    let json =
      `Assoc
        [ ("previous", `String previous_file)
        ; ("current", `String current_file)
        ; ("outcome", `String outcome)
        ; ("diff", `List (List.map ~f:(fun diff -> `String diff) diffs)) ]
    in
    Out_channel.with_file out_path ~f:(fun out_channel -> Yojson.Safe.to_channel out_channel json)


  let merge_changes removed added =
    let rec aux removed added acc =
      match (removed, added) with
      | [], [] ->
          List.rev acc
      | a :: as', [] ->
          aux as' [] ((Some a, None) :: acc)
      | [], r :: rs' ->
          aux [] rs' ((None, Some r) :: acc)
      | ((ia, _) as a) :: as', ((ir, _) as r) :: rs' ->
          if Int.equal ia ir then aux as' rs' ((Some a, Some r) :: acc)
          else if ia < ir then aux as' added ((Some a, None) :: acc)
          else aux removed rs' ((None, Some r) :: acc)
    in
    aux added removed []


  let show_diff file1 file2 lines_removed lines_added =
    let lines1 = String.split_on_chars ~on:['\n'] file1
    and lines2 = String.split_on_chars ~on:['\n'] file2 in
    let get_line_content lines n : string =
      if n - 1 < List.length lines then List.nth_exn lines (n - 1) else ""
    in
    let lines_to_string_set lines =
      List.fold_left ~f:(fun acc (_, s) -> StringSet.add s acc) ~init:StringSet.empty lines
    in
    (* Removes changes from left and right when the only difference is the line number to avoid noise in output *)
    let remove_common_changes list1 list2 =
      let set1 = lines_to_string_set list1 in
      let set2 = lines_to_string_set list2 in
      let common = StringSet.inter set1 set2 in
      let keep (_, s) = not (StringSet.mem s common) in
      (List.filter ~f:keep list1, List.filter ~f:keep list2)
    in
    let lines_removed =
      List.map
        ~f:(fun line_number -> (line_number, get_line_content lines1 line_number))
        (IntSet.to_list lines_removed)
    in
    let lines_added =
      List.map
        ~f:(fun line_number -> (line_number, get_line_content lines2 line_number))
        (IntSet.to_list lines_added)
    in
    let lines_removed, lines_added = remove_common_changes lines_removed lines_added in
    let diffs = merge_changes lines_added lines_removed in
    List.map
      ~f:(fun (line_removed, line_added) ->
        match (line_removed, line_added) with
        | Some (line_number, line_content), None ->
            Printf.sprintf "(Line %d) - %s" line_number line_content
        | Some (line_number, line_content_removed), Some (_, line_content_added) ->
            Printf.sprintf "(Line %d) - %s, + %s" line_number line_content_removed
              line_content_added
        | None, Some (line_number, line_content_added) ->
            Printf.sprintf "(Line %d) + %s" line_number line_content_added
        | None, None ->
            "" )
      diffs
end

(* ===== Public API ===== *)
let ast_diff ?(debug = false) src1 src2 =
  let parse_func = init () in
  let ast1 = parse_and_transform parse_func src1 in
  let ast2 = parse_and_transform parse_func src2 in
  let diffs = Diff.get_diff ast1 ast2 in
  let lines_removed, lines_added = Diff.split_diffs diffs in
  let diffs = Output.show_diff src1 src2 lines_removed lines_added in
  if debug then (
    Printf.printf "AST1: %s\n" (AstNode.to_str ast1) ;
    Printf.printf "AST2: %s\n" (AstNode.to_str ast2) ;
    Printf.printf "SemDiff:\n%s\n" (String.concat ~sep:"\n" diffs) ) ;
  diffs


let semdiff previous_file current_file =
  let debug = Config.debug_mode in
  let previous_src = In_channel.with_file previous_file ~f:In_channel.input_all in
  let current_src = In_channel.with_file current_file ~f:In_channel.input_all in
  let diffs = ast_diff ~debug previous_src current_src in
  Output.write_output previous_file current_file diffs
