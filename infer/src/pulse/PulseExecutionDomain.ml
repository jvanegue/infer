(*
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 *)

open! IStd
module F = Format
open PulseBasicInterface

module AbductiveDomain = PulseAbductiveDomain
module DecompilerExpr = PulseDecompilerExpr
module Diagnostic = PulseDiagnostic
module LatentIssue = PulseLatentIssue
module Formula = PulseFormula
module L = Logging
module Metadata = AbstractInterpreter.DisjunctiveMetadata
         
(* The type variable is needed to distinguish summaries from plain states.

   Some of the variants have summary-typed states instead of plain states, to ensure we have
   normalized them and don't need to normalize them again. *)
type 'abductive_domain_t base_t =
  | ContinueProgram of 'abductive_domain_t
  | InfiniteProgram of 'abductive_domain_t 
  | ExceptionRaised of 'abductive_domain_t
  | ExitProgram of AbductiveDomain.Summary.t
  | AbortProgram of AbductiveDomain.Summary.t
  | LatentAbortProgram of {astate: AbductiveDomain.Summary.t; latent_issue: LatentIssue.t}
  | LatentInvalidAccess of
      { astate: AbductiveDomain.Summary.t
      ; address: DecompilerExpr.t
      ; must_be_valid: (Trace.t * Invalidation.must_be_valid_reason option[@yojson.opaque])
      ; calling_context: ((CallEvent.t * Location.t) list[@yojson.opaque]) }
  | LatentSpecializedTypeIssue of
      { astate: AbductiveDomain.Summary.t
      ; specialized_type: Typ.Name.t
      ; trace: (Trace.t[@yojson.opaque]) }
[@@deriving equal, compare, yojson_of, variants]

type t = AbductiveDomain.t base_t
       
let continue astate = ContinueProgram astate

let leq ~lhs ~rhs =
  phys_equal lhs rhs
  ||
  match (lhs, rhs) with
  | AbortProgram astate1, AbortProgram astate2 | ExitProgram astate1, ExitProgram astate2 ->
      AbductiveDomain.Summary.leq ~lhs:astate1 ~rhs:astate2
  | ExceptionRaised astate1, ExceptionRaised astate2
  | InfiniteProgram astate1, InfiniteProgram astate2
  | ContinueProgram astate1, ContinueProgram astate2 ->
      AbductiveDomain.leq ~lhs:astate1 ~rhs:astate2
  | ( LatentAbortProgram {astate= astate1; latent_issue= issue1}
    , LatentAbortProgram {astate= astate2; latent_issue= issue2} ) ->
      LatentIssue.equal issue1 issue2 && AbductiveDomain.Summary.leq ~lhs:astate1 ~rhs:astate2
  | ( LatentInvalidAccess {astate= astate1; address= v1; must_be_valid= _}
    , LatentInvalidAccess {astate= astate2; address= v2; must_be_valid= _} ) ->
      DecompilerExpr.equal v1 v2 && AbductiveDomain.Summary.leq ~lhs:astate1 ~rhs:astate2
  | _ ->
      false

let to_astate = function
  | AbortProgram summary
  | ExitProgram summary
  | LatentAbortProgram {astate= summary}
  | LatentInvalidAccess {astate= summary}
  | LatentSpecializedTypeIssue {astate= summary} ->
      (summary :> AbductiveDomain.t)
  | ExceptionRaised astate | ContinueProgram astate | InfiniteProgram astate ->
      astate

let pp_header kind fmt = function
  | InfiniteProgram _ ->
     Pp.with_color kind Red F.pp_print_string fmt "InfiniteProgram"
  | AbortProgram _ ->
      Pp.with_color kind Red F.pp_print_string fmt "AbortProgram"
  | ContinueProgram _ ->
      ()
  | ExceptionRaised _ ->
      Pp.with_color kind Orange F.pp_print_string fmt "ExceptionRaised"
  | ExitProgram _ ->
      Pp.with_color kind Orange F.pp_print_string fmt "ExitProgram"
  | LatentAbortProgram {latent_issue} ->
      Pp.with_color kind Orange F.pp_print_string fmt "LatentAbortProgram" ;
      let diagnostic = LatentIssue.to_diagnostic latent_issue in
      let message, _suggestion = Diagnostic.get_message_and_suggestion diagnostic in
      let location = Diagnostic.get_location diagnostic in
      F.fprintf fmt "(%a: %s)@ %a" Location.pp location message LatentIssue.pp latent_issue
  | LatentInvalidAccess {address; must_be_valid= _} ->
      Pp.with_color kind Orange F.pp_print_string fmt "LatentInvalidAccess" ;
      F.fprintf fmt "(%a)" DecompilerExpr.pp address
  | LatentSpecializedTypeIssue {specialized_type; trace} ->
      Pp.with_color kind Orange F.pp_print_string fmt "LatentSpecializedTypeIssue" ;
      let origin_location = Trace.get_start_location trace in
      F.fprintf fmt "(%a: %a)" Location.pp origin_location Typ.Name.pp specialized_type

let pp_with_kind kind path_opt fmt exec_state =
  F.fprintf fmt "%a%a" (pp_header kind) exec_state (PulsePp.pp kind path_opt) (to_astate exec_state)


let pp fmt (exec_state: 'abductive_domain_t base_t) = 
 F.fprintf fmt "%a%a" (pp_header TEXT) exec_state AbductiveDomain.pp (to_astate exec_state)

(* Pulse infinite *)
(* We record the global widening state *)
(* Note: this will record the widen state once per analyzed object, which may not be enough *)
(* TODO: Find out how to have one widen state key per loop *)                      
let widenstate = ref None;; 
let () = AnalysisGlobalState.register_ref ~init:(fun () -> Some (Caml.Hashtbl.create 16)) widenstate;;

let back_edge (prev: t list) (next: t list) (num_iters: int)  : t list * int =

  (* L.debug Analysis Quiet "PULSEINF: Entered BACK-EDGE! \n"; *)
  
  let _ = num_iters in
  
  (* Instead of this, we want to stop reporting at current and next widening iteration 
     if we already have had an alert at a previous widening iteration *)
  (* if (num_iters <= 0) then next,-1 else *)
  (* It looks like infer reporting will filter issues by location to avoid duplicate already *)

  let cfgnode = (Metadata.get_cfg_node ()) in  
  let same = phys_equal prev next in

  (* Future work: implement a more generic way to check for recurring sets than filtering on the path condition *)
  (* 
     let substate _ _ = false (* TODO *) 
     in 
     let rec find_equiv_elem e lst =
         match lst with
         | [] -> false
         | hd::tl -> if (substate hd e) then true else (find_equiv_elem e tl)
     in
   *)
  
  let rec detect_elem e lst curi : bool * int =
    match lst with
    | [] -> false,-1
    | hd::tl -> if (leq ~lhs:hd ~rhs:e) then (true,curi) else (detect_elem e tl (curi + 1))
  in
  
  let rec compute_workset prev next newset nextit : (t * int) list =
    match next with
    | [] -> newset
    | hd::tl ->
       let res,idx = detect_elem hd prev 0 in
       (* L.debug Analysis Quiet "JV: compute_workset find res = %b idx %u \n" res idx; *)

       (* record the idx of the new state in postcond (next) *)
       let recidx = (match idx with | -1 -> nextit | _ -> idx)
       in
       if (res)
       then (compute_workset prev tl newset (nextit + 1))
       else [(hd,recidx)] @ (compute_workset prev tl newset (nextit + 1))
  in
  let workset = (compute_workset prev next [] 0) in
  let prevlen = List.length(prev) in
  let nextlen = List.length(next) in
  let worklen = List.length(workset) in

  (* L.debug Analysis Quiet "PULSEINF: BACKEDGE prevlen %d nextlen %d diff %d worklen %d \n" prevlen nextlen (nextlen - prevlen) worklen; *)
  (* Do-nothing version to avoid debug output *)
  (* let print_workset _ = true in  *) (* L.debug Analysis Quiet "JV: Computing Workset at numiter %i \n" num_iters; true in *)  
  (* Pulse-inf debug output: useful but verbose *)
  let rec print_workset ws =
    match ws with
    | [] -> true
    | (hd,_)::tl ->                 
       pp Format.err_formatter hd;
       print_workset tl
  in

  (* Use this when disabling debug output *)
  (* let print_warning _ _ _ = () in *)

  let _ = print_workset workset in
  
  let print_warning s cnt state =
    let _ = state in 
    L.debug Analysis Quiet "JV: FOUND infinite state from %s with cnt %i \n" s cnt; 
    pp Format.std_formatter state; 
    L.debug Analysis Quiet "JV: End infinite state -- now printing workset at bug location \n";
    let _ = print_workset workset in
    L.debug Analysis Quiet "JV: End Printing Vulnerable Workset \n"
  in
  
  let extract_pathcond hd : Formula.t =
   match hd with
    | AbortProgram summary -> AbductiveDomain.Summary.get_path_condition summary
    | ExitProgram summary -> AbductiveDomain.Summary.get_path_condition summary
    | LatentAbortProgram a -> AbductiveDomain.Summary.get_path_condition a.astate
    | LatentInvalidAccess a -> AbductiveDomain.Summary.get_path_condition a.astate
    | InfiniteProgram astate -> AbductiveDomain.get_path_condition astate
    | ExceptionRaised astate -> AbductiveDomain.get_path_condition astate
    | ContinueProgram astate -> AbductiveDomain.get_path_condition astate                             
    | LatentSpecializedTypeIssue {astate; _} -> AbductiveDomain.Summary.get_path_condition astate
  in
  
  let rec record_pathcond ws : int =
    match ws with
    | [] -> -1
    | (hd,idx)::tl ->
       match !widenstate with
       | None -> L.debug Analysis Quiet "PULSEINF: widenstate htable NONE - should never happen! \n"; -1
       | Some wstate ->
          let cond = extract_pathcond hd in
          let pathcond = Formula.extract_path_cond cond in
          let termcond = Formula.extract_term_cond cond in
          let termcond2 = Formula.extract_term_cond2 cond in
          
          let prevstate = Caml.Hashtbl.find_opt wstate (cfgnode,termcond,pathcond,termcond2) in
          match prevstate with
          | None ->
             Caml.Hashtbl.add wstate (cfgnode,termcond,pathcond,termcond2) (); (* record pathcond of hd *)
             (* L.debug Analysis Quiet "PULSEINF: Recorded pathcond in htable at idx %d (NO BUG) \n" idx; *)
             record_pathcond tl
          | Some _ ->
             match (Formula.set_is_empty termcond),(Formula.set_is_empty pathcond),(Formula.termset_is_empty termcond2) with
             | true,true,true -> (* -2 *)
                (* L.debug Analysis Quiet "PULSEINF: Recorded pathcond ALREADY in htable! (EMPTY) idx %d \n" idx; *) -2 
             | _ -> (* idx *)
                (* L.debug Analysis Quiet "PULSEINF: Recorded pathcond ALREADY in htable! (NON-TERM BUG) idx %d \n" idx; *) idx 
                    
  in
  
  (* let _ = print_workset workset in *)
  let (repeated_wsidx:int) = record_pathcond workset in

  let create_infinite_state (hd:t) (cnt:int) : t =
    (* Only create infinite state from a non-error state that is not already an infinite state *)
    match hd with
    | ExceptionRaised astate -> print_warning "Exception" cnt hd; InfiniteProgram astate
    | ContinueProgram astate -> print_warning "Continue" cnt hd; InfiniteProgram astate
    | AbortProgram astate -> AbortProgram astate
    | ExitProgram astate -> ExitProgram astate
    | LatentAbortProgram a -> LatentAbortProgram a
    | LatentInvalidAccess a -> LatentInvalidAccess a
    | InfiniteProgram astate -> InfiniteProgram astate                                                      
    | LatentSpecializedTypeIssue astate -> LatentSpecializedTypeIssue astate
  in

  let create_infinite_state_and_print (state_set: t list) (idx:int) (case:int) = 

    (* L.debug Analysis Quiet "JV: BUG FOUND - DETECTED REPEATED STATE IDX %d CASE %d numiter %d \n" idx case num_iters; *)

    Metadata.record_alert_node cfgnode;
    
    let nth = (List.nth state_set idx) in 
    match nth with
    | None       ->
       L.debug Analysis Quiet "PULSEINF: create_infinite_state Nth NONE (idx %d case %d) -- should never happen! \n" idx case;
       [],-1
    | Some state ->
       [(create_infinite_state state idx)],idx
  in
  
  let lastelm = (List.length next) in
  let isempty = (phys_equal lastelm 0) || (phys_equal (List.length prev) 0) in

  (* Identify which state in the post is repeated and generate a new infinite state for it *)
  let rec is_repeated e lst : bool = 
      match lst with
      | [] -> false
      | hd::tl -> if (leq ~lhs:e ~rhs:hd) then true else is_repeated e tl
  in
  let rec find_duplicate_state (lst: t list) (curi: int) (maxi: int) : int =
    match lst with
    | hd::tl -> let isrep = (is_repeated hd tl) in
                (* L.debug Analysis Quiet "JV: Found duplicate state in POST with index = %d \n" curi; *)
                if (isrep && curi > maxi) then
                  (find_duplicate_state tl (curi+1) curi)
                else
                  (find_duplicate_state tl (curi+1) maxi)
    | _ -> (* L.debug Analysis Quiet "JV: Chosen duplicate in POST has index = %d \n" maxi; *) maxi 
  in  
  
  (* we have a trivial lasso because prev = next - this should trigger an alert *)
  if same && (phys_equal isempty false) then
    create_infinite_state_and_print next lastelm 1
  (* We have one or more newly created equivalent states in the post, trigger an alert *)
  else if (phys_equal worklen 0) && (nextlen - prevlen) > 0 then
    create_infinite_state_and_print next (find_duplicate_state next 0 (-1)) 2
  (* We have a new post state whose path condition is equivalent to an existing state, trigger an alert *)
  else if repeated_wsidx >= 0 then
    create_infinite_state_and_print next repeated_wsidx 3
  (* No recurring state detected, return empty *)
  else [],-1
         
type summary = AbductiveDomain.Summary.t base_t [@@deriving compare, equal, yojson_of]

let pp_summary fmt (exec_summary : summary) =
  pp_with_kind TEXT None fmt (exec_summary :> AbductiveDomain.t base_t)

let equal_fast exec_state1 exec_state2 =
  phys_equal exec_state1 exec_state2
  ||
  match (exec_state1, exec_state2) with
  | AbortProgram astate1, AbortProgram astate2 | ExitProgram astate1, ExitProgram astate2 ->
      phys_equal astate1 astate2
  | ContinueProgram astate1, ContinueProgram astate2 ->
      phys_equal astate1 astate2
  | _ ->
      false


let is_normal (exec_state : t) : bool =
  match exec_state with ExceptionRaised _ -> false | _ -> true


let is_exceptional (exec_state : t) : bool =
  match exec_state with ExceptionRaised _ -> true | _ -> false


let is_executable (exec_state : t) : bool =
  match exec_state with ContinueProgram _ | ExceptionRaised _ -> true | _ -> false


let exceptional_to_normal : t -> t = function
  | ExceptionRaised astate ->
      ContinueProgram astate
  | x ->
      x


let to_name = Variants_of_base_t.to_name
