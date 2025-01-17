(*
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 *)

open! IStd
module L = Logging
module Map = IInt.Map

let ivar_to_property_table = IInt.Hash.create 256

let pointer_decl_table = IInt.Hash.create 256

let pointer_stmt_table = IInt.Hash.create 256

let pointer_type_table = IInt.Hash.create 256

let empty_v = Clang_ast_visit.empty_visitor

(* This function is not thread-safe *)
let visit_ast ?(visit_decl = empty_v) ?(visit_stmt = empty_v) ?(visit_type = empty_v)
    ?(visit_src_loc = empty_v) top_decl =
  Clang_ast_visit.decl_visitor := visit_decl ;
  Clang_ast_visit.stmt_visitor := visit_stmt ;
  Clang_ast_visit.type_visitor := visit_type ;
  Clang_ast_visit.source_location_visitor := visit_src_loc ;
  match Clang_ast_v.validate_decl [] top_decl (* visit *) with
  | None ->
      ()
  | Some error ->
      L.(die InternalError)
        "visiting the clang AST failed with error %s"
        (Atdgen_runtime.Util.Validation.string_of_error error)


let get_ptr_from_node node =
  match node with
  | `DeclNode decl ->
      let decl_info = Clang_ast_proj.get_decl_tuple decl in
      decl_info.Clang_ast_t.di_pointer
  | `StmtNode stmt ->
      let stmt_info, _ = Clang_ast_proj.get_stmt_tuple stmt in
      stmt_info.Clang_ast_t.si_pointer
  | `TypeNode c_type ->
      let type_info = Clang_ast_proj.get_type_tuple c_type in
      type_info.Clang_ast_t.ti_pointer


let get_val_from_node node =
  match node with `DeclNode decl -> decl | `StmtNode stmt -> stmt | `TypeNode c_type -> c_type


let add_node_to_cache node cache =
  let key = get_ptr_from_node node in
  let data = get_val_from_node node in
  IInt.Hash.replace cache key data


let process_decl _ decl =
  add_node_to_cache (`DeclNode decl) pointer_decl_table ;
  match decl with
  | Clang_ast_t.ObjCPropertyDecl (_, _, {opdi_ivar_decl= Some decl_ref}) ->
      let ivar_pointer = decl_ref.Clang_ast_t.dr_decl_pointer in
      IInt.Hash.replace ivar_to_property_table ivar_pointer decl
  | _ ->
      ()


let add_stmt_to_cache _ stmt = add_node_to_cache (`StmtNode stmt) pointer_stmt_table

let add_type_to_cache _ c_type = add_node_to_cache (`TypeNode c_type) pointer_type_table

let previous_sloc =
  { Clang_ast_t.sl_file= None
  ; sl_line= None
  ; sl_column= None
  ; sl_macro_file= None
  ; sl_macro_line= None
  ; sl_is_macro= false }


let get_sloc current previous = match current with None -> previous | Some _ -> current

let mutate_sloc ~update_macro sloc file line column macro_file macro_line =
  let open Clang_ast_t in
  sloc.sl_file <- file ;
  sloc.sl_line <- line ;
  sloc.sl_column <- column ;
  if update_macro then (
    sloc.sl_macro_file <- macro_file ;
    sloc.sl_macro_line <- macro_line )


let reset_sloc sloc = mutate_sloc ~update_macro:true sloc None None None None None

let complete_source_location _ source_loc =
  let open Clang_ast_t in
  let file = get_sloc source_loc.sl_file previous_sloc.sl_file in
  let line = get_sloc source_loc.sl_line previous_sloc.sl_line in
  let is_src_macro = source_loc.sl_is_macro in
  let macro_file =
    if is_src_macro then get_sloc source_loc.sl_macro_file previous_sloc.sl_macro_file else None
  in
  let macro_line =
    if is_src_macro then get_sloc source_loc.sl_macro_line previous_sloc.sl_macro_line else None
  in
  let column = get_sloc source_loc.sl_column previous_sloc.sl_column in
  mutate_sloc ~update_macro:true source_loc file line column macro_file macro_line ;
  mutate_sloc ~update_macro:source_loc.sl_is_macro previous_sloc file line column macro_file
    macro_line


let reset_cache () =
  IInt.Hash.clear pointer_decl_table ;
  IInt.Hash.clear pointer_stmt_table ;
  IInt.Hash.clear pointer_type_table ;
  IInt.Hash.clear ivar_to_property_table ;
  reset_sloc previous_sloc


(* This function is not thread-safe *)
let populate_all_tables top_decl =
  reset_cache () ;
  (* populate caches *)
  visit_ast ~visit_decl:process_decl ~visit_stmt:add_stmt_to_cache ~visit_type:add_type_to_cache
    ~visit_src_loc:complete_source_location top_decl
