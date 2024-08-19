(*
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 *)

open! IStd
open PulseBasicInterface
open PulseDomainInterface
open PulseOperationResult.Import
open PulseModelsImport
module DSL = PulseModelsDSL
module FuncArg = ProcnameDispatcher.Call.FuncArg

let free deleted_access : model = Basic.free_or_delete `Free CFree deleted_access

let invalidate path access_path location cause addr_trace : unit DSL.model_monad =
  let open DSL.Syntax in
  PulseOperations.invalidate path access_path location cause addr_trace |> exec_command


let alloc_common ~desc allocator ~size_exp_opt : model =
  let open DSL.Syntax in
  start_named_model desc
  @@ let* {path; location; ret= ret_id, _} = get_data in
     let astate_alloc = Basic.alloc_not_null allocator ~initialize:false size_exp_opt in
     let result_null =
       let* ret_addr = mk_fresh ~more:"(null case)" () in
       let* () = assign_ret ret_addr in
       let* () = and_eq_int ret_addr IntLit.zero in
       invalidate path
         (StackAddress (Var.of_id ret_id, snd ret_addr))
         location (ConstantDereference IntLit.zero) ret_addr
     in
     disjuncts [astate_alloc; result_null]


let alloc_not_null_common_dsl allocator ~size_exp_opt : unit DSL.model_monad =
  let open DSL.Syntax in
  Basic.alloc_not_null ~initialize:false allocator size_exp_opt


let alloc_not_null_common ~desc allocator ~size_exp_opt : model =
  let open DSL.Syntax in
  start_named_model desc @@ alloc_not_null_common_dsl allocator ~size_exp_opt


let malloc size_exp = alloc_common ~desc:"malloc" CMalloc ~size_exp_opt:(Some size_exp)

let malloc_not_null size_exp =
  alloc_not_null_common ~desc:"malloc" CMalloc ~size_exp_opt:(Some size_exp)


let custom_malloc size_exp model_data astate =
  alloc_common ~desc:"custom malloc" (CustomMalloc model_data.callee_procname)
    ~size_exp_opt:(Some size_exp) model_data astate


let custom_malloc_not_null size_exp model_data astate =
  alloc_not_null_common ~desc:"custom malloc" (CustomMalloc model_data.callee_procname)
    ~size_exp_opt:(Some size_exp) model_data astate


let custom_alloc_not_null desc model_data astate =
  alloc_not_null_common ~desc (CustomMalloc model_data.callee_procname) ~size_exp_opt:None
    model_data astate


let realloc_common ~desc allocator pointer size : model =
 fun data astate non_disj ->
  free pointer data astate non_disj
  |> NonDisjDomain.bind ~f:(fun result non_disj ->
         let ( let<*> ) x f = bind_sat_result non_disj (Sat x) f in
         let<*> exec_state = result in
         match (exec_state : ExecutionDomain.t) with
         | ContinueProgram astate ->
            alloc_common ~desc allocator ~size_exp_opt:(Some size) data astate non_disj
         | InfiniteProgram _
         | ExceptionRaised _
         | ExitProgram _
         | AbortProgram _
         | LatentAbortProgram _
         | LatentInvalidAccess _
         | LatentSpecializedTypeIssue _ ->
             ([Ok exec_state], non_disj) )


let realloc = realloc_common ~desc:"realloc" CRealloc

let custom_realloc pointer size data astate =
  realloc_common ~desc:"custom realloc" (CustomRealloc data.callee_procname) pointer size data
    astate


let call_c_function_ptr {FuncArg.arg_payload= function_ptr} actuals : model =
 fun {path; analysis_data; location; ret= (ret_id, _) as ret; dispatch_call_eval_args} astate
     non_disj ->
  let callee_proc_name_opt =
    match PulseArithmetic.get_dynamic_type (ValueOrigin.value function_ptr) astate with
    | Some {typ= {desc= Typ.Tstruct (Typ.CFunction csig)}} ->
        Some (Procname.C csig)
    | _ ->
        None
  in
  match callee_proc_name_opt with
  | Some callee_proc_name ->
      dispatch_call_eval_args analysis_data path ret (Const (Cfun callee_proc_name)) actuals
        location CallFlags.default astate non_disj (Some callee_proc_name)
  | None ->
      (* we don't know what procname this function pointer resolves to *)
      let res =
        (* dereference call expression to catch nil issues *)
        let<+> astate, _ =
          PulseOperations.eval_access path Read location
            (ValueOrigin.addr_hist function_ptr)
            Dereference astate
        in
        let desc = Procname.to_string BuiltinDecl.__call_c_function_ptr in
        let hist = Hist.single_event path (Hist.call_event path location desc) in
        let astate = PulseOperations.havoc_id ret_id hist astate in
        let astate =
          AbductiveDomain.add_need_dynamic_type_specialization (ValueOrigin.value function_ptr)
            astate
        in
        let astate =
          let unknown_effect = Attribute.UnknownEffect (Model desc, hist) in
          List.fold actuals ~init:astate ~f:(fun acc FuncArg.{arg_payload= actual} ->
              AddressAttributes.add_one (ValueOrigin.value actual) unknown_effect acc )
        in
        astate
      in
      (res, non_disj)


let matchers : matcher list =
  let open ProcnameDispatcher.Call in
  let match_regexp_opt r_opt (_tenv, proc_name) _ =
    Option.exists r_opt ~f:(fun r ->
        let s = Procname.to_string proc_name in
        Str.string_match r s 0 )
  in
  let map_context_tenv f (x, _) = f x in
  [ +BuiltinDecl.(match_builtin free) <>$ capt_arg $--> free
  ; +match_regexp_opt Config.pulse_model_free_pattern <>$ capt_arg $+...$--> free
  ; -"realloc" <>$ capt_arg $+ capt_exp $--> realloc
  ; +match_regexp_opt Config.pulse_model_realloc_pattern
    <>$ capt_arg $+ capt_exp $+...$--> custom_realloc ]
  @ ( [ ( +BuiltinDecl.(match_builtin malloc)
        <>$ capt_exp
        $--> if Config.pulse_unsafe_malloc then malloc_not_null else malloc )
      ; ( +match_regexp_opt Config.pulse_model_malloc_pattern
        <>$ capt_exp
        $+...$--> if Config.pulse_unsafe_malloc then custom_malloc_not_null else custom_malloc )
      ; +map_context_tenv PatternMatch.ObjectiveC.is_core_graphics_create_or_copy
        &--> custom_alloc_not_null "CGCreate/Copy"
      ; +map_context_tenv PatternMatch.ObjectiveC.is_core_foundation_create_or_copy
        &--> custom_alloc_not_null "CFCreate/Copy"
      ; +BuiltinDecl.(match_builtin malloc_no_fail) <>$ capt_exp $--> malloc_not_null
      ; +match_regexp_opt Config.pulse_model_alloc_pattern &--> custom_alloc_not_null "custom alloc"
      ]
    |> List.map ~f:(ProcnameDispatcher.Call.contramap_arg_payload ~f:ValueOrigin.addr_hist) )
  @ [+BuiltinDecl.(match_builtin __call_c_function_ptr) $ capt_arg $++$--> call_c_function_ptr]
