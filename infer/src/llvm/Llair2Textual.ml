(*
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 *)

open! IStd
open Llair
open Llair2TextualType
module F = Format
module VarMap = Textual.VarName.Map
module IdentMap = Textual.Ident.Map

let builtin_qual_proc_name name : Textual.QualifiedProcName.t =
  { enclosing_class= Enclosing (Textual.TypeName.of_string "$builtins")
  ; name= Textual.ProcName.of_string name }


type proc_state =
  { qualified_name: Textual.QualifiedProcName.t
  ; loc: Textual.Location.t
  ; mutable locals: Textual.Typ.annotated VarMap.t
  ; mutable formals: Textual.Typ.annotated VarMap.t
  ; mutable ids: Textual.Typ.annotated IdentMap.t }

let pp_ids fmt current_ids =
  F.fprintf fmt "%a"
    (Pp.comma_seq (Pp.pair ~fst:Textual.Ident.pp ~snd:Textual.Typ.pp_annotated))
    (IdentMap.bindings current_ids)
[@@warning "-unused-value-declaration"]


let update_current_locals ~proc_state varname typ =
  proc_state.locals <- VarMap.add varname typ proc_state.locals


let update_current_formals ~proc_state varname typ =
  proc_state.formals <- VarMap.add varname typ proc_state.formals


let update_current_ids ~proc_state id typ = proc_state.ids <- IdentMap.add id typ proc_state.ids

let string_name_of_reg reg = Format.sprintf "var%s" (Reg.name reg)

let reg_to_var_name reg = Textual.VarName.of_string (string_name_of_reg reg)

let reg_to_id reg = Textual.Ident.of_int (Reg.id reg)

let reg_to_textual_var ~proc_state reg =
  let reg_var_name = reg_to_var_name reg in
  if VarMap.mem reg_var_name proc_state.formals || VarMap.mem reg_var_name proc_state.locals then
    Textual.Exp.Lvar reg_var_name
  else Textual.Exp.Var (reg_to_id reg)


let reg_to_annot_typ reg = to_annotated_textual_typ (Reg.typ reg)

let to_textual_loc {Loc.line; col} = Textual.Location.Known {line; col}

let is_loc_default loc =
  match loc with
  | Textual.Location.Known {line; col} ->
      Int.equal line 0 && Int.equal col 0
  | _ ->
      false


let to_textual_loc_instr ~proc_state loc =
  let loc = to_textual_loc loc in
  if is_loc_default loc then proc_state.loc else loc


let translate_llair_globals globals =
  let to_textual_global global =
    let global = global.GlobalDefn.name in
    let global_name = Global.name global in
    let name = Textual.VarName.of_string global_name in
    let typ = to_textual_typ (Global.typ global) in
    Textual.Global.{name; typ; attributes= []}
  in
  let globals = StdUtils.iarray_to_list globals in
  List.map ~f:to_textual_global globals


let to_qualified_proc_name ?loc func_name =
  let func_name = FuncName.name func_name in
  let loc = Option.map ~f:to_textual_loc loc in
  Textual.QualifiedProcName.
    {enclosing_class= TopLevel; name= Textual.ProcName.of_string ?loc func_name}


let to_result_type func_name =
  let typ = FuncName.typ func_name in
  to_annotated_textual_typ typ


let to_formals func =
  let to_textual_formal formal = reg_to_var_name formal in
  let to_textual_formal_type formal = reg_to_annot_typ formal in
  let llair_formals = StdUtils.iarray_to_list func.Llair.formals in
  let formals = List.map ~f:to_textual_formal llair_formals in
  let formals_types = List.map ~f:to_textual_formal_type llair_formals in
  (formals, formals_types)


let block_to_node_name block =
  let name = block.Llair.lbl in
  Textual.NodeName.of_string name


let to_textual_arith_exp_builtin (op : Llair.Exp.op2) typ =
  let sil_binop =
    match (op, typ) with
    | Add, Llair.Typ.Integer _ ->
        Binop.PlusA (Some IInt)
    | Sub, Llair.Typ.Integer _ ->
        Binop.MinusA (Some IInt)
    | Mul, Llair.Typ.Integer _ ->
        Binop.Mult (Some IInt)
    | Div, Llair.Typ.Integer _ ->
        Binop.DivI
    | Div, Llair.Typ.Float _ ->
        Binop.DivF
    | Rem, Llair.Typ.Integer _ ->
        Binop.Mod
    | _ ->
        assert false
  in
  Textual.ProcDecl.of_binop sil_binop


let to_textual_bool_exp_builtin (op : Llair.Exp.op2) =
  let sil_bin_op =
    match op with
    | Eq ->
        Binop.Eq
    | Dq ->
        Binop.Ne
    | Gt ->
        Binop.Gt
    | Ge ->
        Binop.Ge
    | Le ->
        Binop.Le
    | And ->
        Binop.LAnd
    | Or ->
        Binop.LOr
    | Xor ->
        Binop.BXor
    | Shl ->
        Binop.Shiftlt
    | Lshr ->
        Binop.Shiftrt
    | Ashr ->
        Binop.Shiftrt
    | _ ->
        assert false
  in
  Textual.ProcDecl.of_binop sil_bin_op


let rec to_textual_exp ~proc_state ?generate_typ_exp (exp : Llair.Exp.t) :
    Textual.Exp.t * Textual.Typ.t option =
  match exp with
  | Integer {data; typ} ->
      let textual_typ = to_textual_typ typ in
      let textual_exp =
        if Option.is_some generate_typ_exp then Textual.Exp.Typ textual_typ
        else if NS.Z.is_false data && not (Llair.Typ.is_int typ) then Textual.Exp.Const Null
        else Textual.Exp.Const (Int data)
      in
      (textual_exp, Some textual_typ)
  | Float {data; typ} ->
      let textual_typ = to_textual_typ typ in
      let textual_exp =
        if Option.is_some generate_typ_exp then Textual.Exp.Typ (to_textual_typ typ)
        else Textual.Exp.Const (Float (Float.of_string data))
      in
      (textual_exp, Some textual_typ)
  | FuncName {name} ->
      (Textual.Exp.Const (Str name), None)
  | Reg {id; name; typ} ->
      let textual_typ = to_textual_typ typ in
      let textual_exp = reg_to_textual_var ~proc_state (Reg.mk typ id name) in
      (textual_exp, Some textual_typ)
  | Global {name; typ} ->
      let textual_typ = to_textual_typ typ in
      let textual_exp = Textual.Exp.Lvar (Textual.VarName.of_string name) in
      (textual_exp, Some textual_typ)
  | Ap1 (Select n, Struct {name}, exp) ->
      let typ_name = Textual.TypeName.of_string name in
      ( Textual.Exp.Field
          { exp= to_textual_exp ~proc_state exp |> fst
          ; field=
              { enclosing_class= typ_name
              ; name= Textual.FieldName.of_string (Llair2TextualType.field_of_pos n) } }
      , None )
  | Ap1 ((Convert _ | Signed _ | Unsigned _), dst_typ, exp) ->
      (* Signed is the translation of llvm's trunc and SExt and Unsigned is the translation of ZExt, all different types of cast,
         and convert translates other types of cast *)
      let exp = to_textual_exp ~proc_state exp |> fst in
      let textual_dst_typ = to_textual_typ dst_typ in
      let proc = Textual.ProcDecl.cast_name in
      (Call {proc; args= [Textual.Exp.Typ textual_dst_typ; exp]; kind= Textual.Exp.NonVirtual}, None)
  | Ap1 (Splat, _, _) ->
      (* [splat exp] initialises every element of an array with the element exp, so to be precise it
         needs to be translated as a loop. We translate here to a non-deterministic value for the array *)
      let proc = builtin_qual_proc_name "llvm_nondet" in
      (Call {proc; args= []; kind= Textual.Exp.NonVirtual}, None)
  | Ap2 (((Add | Sub | Mul | Div | Rem) as op), typ, e1, e2) ->
      let proc = to_textual_arith_exp_builtin op typ in
      let exp1, typ1 = to_textual_exp ~proc_state e1 in
      let exp2, _ = to_textual_exp ~proc_state e2 in
      (Call {proc; args= [exp1; exp2]; kind= Textual.Exp.NonVirtual}, typ1)
  | Ap2 (((Eq | Dq | Gt | Ge | Le | And | Or | Xor | Shl | Lshr | Ashr) as op), _, e1, e2) ->
      let proc = to_textual_bool_exp_builtin op in
      let exp1, typ1 = to_textual_exp ~proc_state e1 in
      let exp2, _ = to_textual_exp ~proc_state e2 in
      (Call {proc; args= [exp1; exp2]; kind= Textual.Exp.NonVirtual}, typ1)
  | _ ->
      assert false


let to_textual_bool_exp ~proc_state exp =
  let textual_exp, textual_typ_opt = to_textual_exp ~proc_state exp in
  (Textual.BoolExp.Exp textual_exp, textual_typ_opt)


let to_textual_call_aux ~proc_state ~kind ?exp_opt proc return ?generate_typ_exp args loc =
  let loc = to_textual_loc_instr ~proc_state loc in
  let id = Option.map return ~f:(fun reg -> reg_to_id reg) in
  let args =
    List.map ~f:(fun exp -> to_textual_exp ~proc_state ?generate_typ_exp exp |> fst) args
  in
  let args = List.append (Option.to_list exp_opt) args in
  Textual.Instr.Let {id; exp= Call {proc; args; kind}; loc}


let to_textual_call ~proc_state (call : 'a Llair.call) =
  let proc, kind, exp_opt =
    match call.callee with
    | Direct {func} ->
        (to_qualified_proc_name func.Llair.name, Textual.Exp.NonVirtual, None)
    | Indirect {ptr} ->
        let proc = builtin_qual_proc_name "llvm_dynamic_call" in
        (proc, Textual.Exp.NonVirtual, Some (to_textual_exp ~proc_state ptr |> fst))
    | Intrinsic intrinsic ->
        let proc = builtin_qual_proc_name (Llair.Intrinsic.to_name intrinsic) in
        (proc, Textual.Exp.NonVirtual, None)
  in
  let args = StdUtils.iarray_to_list call.actuals in
  to_textual_call_aux ~proc_state ~kind ?exp_opt proc call.areturn args call.loc


let to_textual_builtin ~proc_state return name args loc =
  let proc = builtin_qual_proc_name name in
  to_textual_call_aux ~proc_state ~kind:Textual.Exp.NonVirtual proc return args loc


let update_local_or_formal_type ~proc_state exp typ =
  match exp with
  | Textual.Exp.Lvar var_name when VarMap.mem var_name proc_state.locals ->
      let typ = Textual.Typ.mk_without_attributes typ in
      update_current_locals ~proc_state var_name typ
  | Textual.Exp.Lvar var_name when VarMap.mem var_name proc_state.formals ->
      let typ = Textual.Typ.mk_without_attributes typ in
      update_current_formals ~proc_state var_name typ
  | Textual.Exp.Var id when IdentMap.mem id proc_state.ids ->
      let new_ptr_typ = Textual.Typ.Ptr typ in
      update_current_ids ~proc_state id (Textual.Typ.mk_without_attributes new_ptr_typ)
  | _ ->
      ()


let cmnd_to_instrs ~proc_state block =
  let to_instr textual_instrs inst =
    match inst with
    | Load {reg; ptr; loc} ->
        let loc = to_textual_loc_instr ~proc_state loc in
        let id = reg_to_id reg in
        let reg_typ = to_textual_typ (Reg.typ reg) in
        update_current_ids ~proc_state id (Textual.Typ.mk_without_attributes reg_typ) ;
        let exp, _ = to_textual_exp ~proc_state ptr in
        update_local_or_formal_type ~proc_state exp reg_typ ;
        let textual_instr = Textual.Instr.Load {id; exp; typ= Some reg_typ; loc} in
        textual_instr :: textual_instrs
    | Store {ptr; exp; loc} ->
        let loc = to_textual_loc_instr ~proc_state loc in
        let exp2, typ_exp2 = to_textual_exp ~proc_state exp in
        let exp2, exp2_instrs =
          match (exp, exp2) with
          | Llair.Exp.Reg {id; typ}, Textual.Exp.Lvar _ ->
              let id = Textual.Ident.of_int id in
              let new_exp2 = Textual.Exp.Var id in
              let reg_typ = to_textual_typ typ in
              update_current_ids ~proc_state id (Textual.Typ.mk_without_attributes reg_typ) ;
              let exp2_instr = Textual.Instr.Load {id; exp= exp2; typ= Some reg_typ; loc} in
              (new_exp2, [exp2_instr])
          | _ ->
              (exp2, [])
        in
        let exp1, _ = to_textual_exp ~proc_state ptr in
        let typ_exp2 =
          Option.map
            ~f:(fun typ_exp2 ->
              update_local_or_formal_type ~proc_state exp1 typ_exp2 ;
              typ_exp2 )
            typ_exp2
        in
        let textual_instr = Textual.Instr.Store {exp1; typ= typ_exp2; exp2; loc} in
        (textual_instr :: exp2_instrs) @ textual_instrs
    | Alloc {reg} ->
        let reg_var_name = reg_to_var_name reg in
        let ptr_typ = to_annotated_textual_typ (Reg.typ reg) in
        update_current_locals ~proc_state reg_var_name ptr_typ ;
        textual_instrs
    | Free _ ->
        textual_instrs
    | Nondet {reg; loc} ->
        let textual_instr = to_textual_builtin ~proc_state reg "llvm_nondet" [] loc in
        textual_instr :: textual_instrs
    | Builtin {reg; name; args; loc} when Llair.Builtin.equal name `malloc -> (
        let proc = Textual.ProcDecl.malloc_name in
        match StdUtils.iarray_to_list args with
        | [((Llair.Exp.Integer _ | Llair.Exp.Float _) as exp)] ->
            let textual_instr =
              to_textual_call_aux ~proc_state ~generate_typ_exp:(Some true)
                ~kind:Textual.Exp.NonVirtual proc reg [exp] loc
            in
            textual_instr :: textual_instrs
        | _ ->
            assert false )
    | Builtin {reg; name; args; loc} ->
        let name = Llair.Builtin.to_name name in
        let args = StdUtils.iarray_to_list args in
        let textual_instr = to_textual_builtin ~proc_state reg name args loc in
        textual_instr :: textual_instrs
    | Move {reg_exps: (Reg.t * Exp.t) NS.iarray; loc} ->
        let reg_exps = StdUtils.iarray_to_list reg_exps in
        let exps = List.concat_map ~f:(fun (reg, exp) -> [Reg.to_exp reg; exp]) reg_exps in
        let textual_instr = to_textual_builtin ~proc_state None "llvm_move" exps loc in
        textual_instr :: textual_instrs
    | AtomicRMW {reg; ptr; exp; loc} ->
        let textual_instr =
          to_textual_builtin ~proc_state (Some reg) "llvm_atomicRMW" [ptr; exp] loc
        in
        textual_instr :: textual_instrs
    | AtomicCmpXchg {reg; ptr; cmp; exp; loc} ->
        let textual_instr =
          to_textual_builtin ~proc_state (Some reg) "llvm_atomicCmpXchg" [ptr; cmp; exp] loc
        in
        textual_instr :: textual_instrs
  in
  let call_instr_opt =
    match block.term with Call call -> Some (to_textual_call ~proc_state call) | _ -> None
  in
  let rev_instrs = List.fold ~init:[] ~f:to_instr (StdUtils.iarray_to_list block.cmnd) in
  let instrs = List.rev rev_instrs in
  let first_loc, last_loc =
    match (instrs, rev_instrs) with
    | first :: _, last :: _ ->
        (Some (Textual.Instr.loc first), Some (Textual.Instr.loc last))
    | _ ->
        (None, None)
  in
  (List.append instrs (Option.to_list call_instr_opt), first_loc, last_loc)


let rec to_textual_jump_and_succs ~proc_state ~seen_nodes jump =
  let block = jump.dst in
  let node_label = block_to_node_name block in
  let node_label, succs =
    (* If we've seen this node, stop the recursion *)
    if Textual.NodeName.Set.mem node_label seen_nodes then (node_label, Textual.Node.Set.empty)
    else
      let node, _, nodes = block_to_node_and_succs ~proc_state ~seen_nodes jump.dst in
      (node.label, nodes)
  in
  let node_call = Textual.Terminator.{label= node_label; ssa_args= []} in
  (Textual.Terminator.Jump [node_call], None, succs)


and to_terminator_and_succs ~proc_state ~seen_nodes term :
    (Textual.Terminator.t * Textual.Typ.t option * Textual.Node.Set.t) * Textual.Location.t option =
  let no_succs = Textual.Node.Set.empty in
  match term with
  | Call {return; loc} ->
      let loc = to_textual_loc_instr ~proc_state loc in
      (to_textual_jump_and_succs ~proc_state ~seen_nodes return, Some loc)
  | Return {exp= Some exp; loc} ->
      let textual_exp, textual_typ_opt = to_textual_exp ~proc_state exp in
      let loc = to_textual_loc_instr ~proc_state loc in
      ((Textual.Terminator.Ret textual_exp, textual_typ_opt, no_succs), Some loc)
  | Return {exp= None; loc} ->
      let loc = to_textual_loc_instr ~proc_state loc in
      ((Textual.Terminator.Ret (Textual.Exp.Typ Textual.Typ.Void), None, no_succs), Some loc)
  | Throw {exc; loc} ->
      let loc = to_textual_loc_instr ~proc_state loc in
      ((Textual.Terminator.Throw (to_textual_exp ~proc_state exc |> fst), None, no_succs), Some loc)
  | Switch {key; tbl; els} -> (
    match StdUtils.iarray_to_list tbl with
    | [(exp, zero_jump)] when Exp.equal exp Exp.false_ ->
        (* if then else *)
        let bexp = to_textual_bool_exp ~proc_state key |> fst in
        let else_, _, zero_nodes = to_textual_jump_and_succs ~proc_state ~seen_nodes zero_jump in
        let then_, _, els_nodes = to_textual_jump_and_succs ~proc_state ~seen_nodes els in
        let term = Textual.Terminator.If {bexp; then_; else_} in
        let nodes = Textual.Node.Set.union zero_nodes els_nodes in
        ((term, None, nodes), None)
    | [] when Exp.equal key Exp.false_ ->
        (* goto *)
        (to_textual_jump_and_succs ~proc_state ~seen_nodes els, None)
    | _ ->
        ((Textual.Terminator.Unreachable, None, no_succs), None (* TODO translate Switch *)) )
  | Iswitch _ | Abort _ | Unreachable ->
      ((Textual.Terminator.Unreachable, None, no_succs), None)


(* TODO still various parts of the node left to be translated *)
and block_to_node_and_succs ~proc_state ~seen_nodes (block : Llair.block) :
    Textual.Node.t * Textual.Typ.t option * Textual.Node.Set.t =
  let node_name = block_to_node_name block in
  let (terminator, typ_opt, succs), term_loc_opt =
    to_terminator_and_succs ~proc_state
      ~seen_nodes:(Textual.NodeName.Set.add node_name seen_nodes)
      block.term
  in
  let instrs, first_loc, last_loc = cmnd_to_instrs ~proc_state block in
  let last_loc =
    match term_loc_opt with
    | Some loc ->
        loc
    | None ->
        Option.value last_loc ~default:Textual.Location.Unknown
  in
  let first_loc =
    match first_loc with
    | Some loc ->
        loc
    | None when List.is_empty (StdUtils.iarray_to_list block.cmnd) ->
        last_loc
    | _ ->
        Textual.Location.Unknown
  in
  let node =
    Textual.Node.
      { label= node_name
      ; ssa_parameters= []
      ; exn_succs= []
      ; last= terminator
      ; instrs
      ; last_loc
      ; label_loc= first_loc }
  in
  (* We add the nodes here to make sure they always get added even in the case of recursive jumps *)
  (node, typ_opt, Textual.Node.Set.add node succs)


let func_to_nodes ~proc_state func =
  let _, typ_opt, nodes =
    block_to_node_and_succs ~proc_state ~seen_nodes:Textual.NodeName.Set.empty func.Llair.entry
  in
  (typ_opt, Textual.Node.Set.to_list nodes)


let is_undefined func =
  let entry = func.Llair.entry in
  match entry.term with
  | Unreachable ->
      String.equal entry.lbl "undefined" && List.is_empty (StdUtils.iarray_to_list entry.cmnd)
  | _ ->
      false


type textual_proc = ProcDecl of Textual.ProcDecl.t | ProcDesc of Textual.ProcDesc.t

let translate_llair_functions functions =
  let function_to_formal proc_descs (func_name, func) =
    let formals_list, formals_types = to_formals func in
    let qualified_name = to_qualified_proc_name func_name ~loc:func.Llair.loc in
    let proc_loc = to_textual_loc func.Llair.loc in
    let formals_ =
      List.fold2_exn
        ~f:(fun formals varname typ -> Textual.VarName.Map.add varname typ formals)
        formals_list formals_types ~init:Textual.VarName.Map.empty
    in
    let proc_state =
      {qualified_name; loc= proc_loc; formals= formals_; locals= VarMap.empty; ids= IdentMap.empty}
    in
    let typ_opt, nodes = func_to_nodes ~proc_state func in
    let result_type =
      match typ_opt with
      | Some typ ->
          {typ; Textual.Typ.attributes= []}
      | None ->
          to_result_type func_name
    in
    let formals_types =
      List.map ~f:(fun formal -> VarMap.find formal proc_state.formals) formals_list
    in
    let procdecl =
      Textual.ProcDecl.
        {qualified_name; result_type; attributes= []; formals_types= Some formals_types}
    in
    if is_undefined func then ProcDecl procdecl :: proc_descs
    else
      let locals =
        VarMap.fold (fun varname typ locals -> (varname, typ) :: locals) proc_state.locals []
      in
      ProcDesc
        Textual.ProcDesc.
          { params= formals_list
          ; locals
          ; procdecl
          ; start= block_to_node_name func.Llair.entry
          ; nodes
          ; exit_loc= Unknown (* TODO: get this location *) }
      :: proc_descs
  in
  let values = FuncName.Map.to_list functions in
  List.fold values ~f:function_to_formal ~init:[]


let translate sourcefile (llair_program : Llair.Program.t) lang : Textual.Module.t =
  let globals = translate_llair_globals llair_program.Llair.globals in
  let procs = translate_llair_functions llair_program.Llair.functions in
  let procs =
    List.fold
      ~f:(fun procs proc ->
        match proc with
        | ProcDecl proc_decl ->
            Textual.Module.Procdecl proc_decl :: procs
        | ProcDesc proc_desc ->
            Textual.Module.Proc proc_desc :: procs )
      procs ~init:[]
  in
  let globals = List.map ~f:(fun global -> Textual.Module.Global global) globals in
  let structs =
    List.map
      ~f:(fun (_, struct_) -> Textual.Module.Struct struct_)
      (Textual.TypeName.Map.bindings !Llair2TextualType.structMap)
  in
  let decls = List.append procs globals in
  let decls = List.append decls structs in
  let attrs = [Textual.Attr.mk_source_language lang] in
  Textual.Module.{attrs; decls; sourcefile}
