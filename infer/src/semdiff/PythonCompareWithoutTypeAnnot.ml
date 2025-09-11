(*
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 *)

open! IStd

let init () =
  let () = if not (Py.is_initialized ()) then Py.initialize ~interpreter:Version.python_exe () in
  let strip_annotations_code =
    {|
import ast
def strip_type_annotations(tree):
    class TypeAnnotationRemover(ast.NodeTransformer):
        def _remove_arg_annotations(self, args):
            return [ast.arg(arg=a.arg, annotation=None) for a in args]
        def visit_FunctionDef(self, node):
            node.returns = None
            node.args.args = self._remove_arg_annotations(node.args.args)
            node.args.kwonlyargs = self._remove_arg_annotations(node.args.kwonlyargs)
            return self.generic_visit(node)
        def visit_AsyncFunctionDef(self, node):
            node.returns = None
            node.args.args = self._remove_arg_annotations(node.args.args)
            node.args.kwonlyargs = self._remove_arg_annotations(node.args.kwonlyargs)
            return self.generic_visit(node)
        def visit_AnnAssign(self, node):
            # Convert annotated assignment to normal assignment
            return ast.Assign(targets=[node.target], value=node.value)
        def visit_ImportFrom(self, node):
            return None
        def visit_Import(self, node):
            return None
    class ClassEqualityToIsInstanceTransformer(ast.NodeTransformer):
        def visit_Compare(self, node):
            # Look for: x.__class__ == Type
            if (isinstance(node.left, ast.Attribute) and
                node.left.attr == '__class__' and
                len(node.ops) == 1 and
                isinstance(node.ops[0], ast.Eq) and
                len(node.comparators) == 1):
                    obj = node.left.value
                    type_node = node.comparators[0]
                    new_node = ast.Call(
                      func=ast.Name(id='isinstance', ctx=ast.Load()),
                      args=[obj, type_node],
                      keywords=[]
                    )
                    return ast.copy_location(new_node, node)
            return self.generic_visit(node)
    return ClassEqualityToIsInstanceTransformer().visit(TypeAnnotationRemover().visit(tree))
  |}
  in
  let ast_module = Py.Import.import_module "ast" in
  let main_module = Py.Import.import_module "__main__" in
  let _ = Py.Run.simple_string strip_annotations_code in
  let strip_func = Py.Module.get main_module "strip_type_annotations" in
  let dump_func = Py.Module.get ast_module "dump" |> Py.Callable.to_function_with_keywords in
  (strip_func, ast_module, dump_func)


let parse_and_strip strip_func ast_module source =
  let parse_func = Py.Module.get ast_module "parse" |> Py.Callable.to_function in
  let tree = parse_func [|Py.String.of_string source|] in
  Py.Callable.to_function strip_func [|tree|]


let ast_to_string dump_func ast = dump_func [|ast|] [] |> Py.String.to_string

let rec diff_lines l1 l2 =
  match (l1, l2) with
  | [], [] ->
      []
  | x :: xs, [] ->
      ("- " ^ x) :: diff_lines xs []
  | [], y :: ys ->
      ("+ " ^ y) :: diff_lines [] ys
  | x :: xs, y :: ys ->
      if String.equal x y then diff_lines xs ys else ("- " ^ x) :: ("+ " ^ y) :: diff_lines xs ys


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


let ast_diff ?(debug = false) src1 src2 =
  let strip_func, ast_module, dump_func = init () in
  let ast1 = parse_and_strip strip_func ast_module src1 in
  let ast2 = parse_and_strip strip_func ast_module src2 in
  let s1 = ast_to_string dump_func ast1 in
  let s2 = ast_to_string dump_func ast2 in
  let lines1 = String.split_on_chars ~on:['\n'] s1 in
  let lines2 = String.split_on_chars ~on:['\n'] s2 in
  let equal = String.equal s1 s2 in
  let diffs = if equal then [] else diff_lines lines1 lines2 in
  if debug then (
    Printf.printf "SemDiff:\n" ;
    List.iter ~f:print_endline diffs ) ;
  diffs


let semdiff ?debug previous_file current_file =
  let previous_src = In_channel.with_file previous_file ~f:In_channel.input_all in
  let current_src = In_channel.with_file current_file ~f:In_channel.input_all in
  let diffs = ast_diff ?debug previous_src current_src in
  write_output previous_file current_file diffs
