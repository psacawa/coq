(************************************************************************)
(*  v      *   The Coq Proof Assistant  /  The Coq Development Team     *)
(* <O___,, *   INRIA - CNRS - LIX - LRI - PPS - Copyright 1999-2018     *)
(*   \VV/  **************************************************************)
(*    //   *      This file is distributed under the terms of the       *)
(*         *       GNU Lesser General Public License Version 2.1        *)
(************************************************************************)

open Names
open Constr
open Decl_kinds
open Constrexpr
open Vernacexpr

(** {6 Fixpoints and cofixpoints} *)

(** Entry points for the vernacular commands Fixpoint and CoFixpoint *)

val do_fixpoint :
  (* When [false], assume guarded. *)
  locality -> polymorphic -> (fixpoint_expr * decl_notation list) list -> unit

val do_cofixpoint :
  (* When [false], assume guarded. *)
  locality -> polymorphic -> (cofixpoint_expr * decl_notation list) list -> unit

(************************************************************************)
(** Internal API  *)
(************************************************************************)

type structured_fixpoint_expr = {
  fix_name : Id.t;
  fix_univs : Vernacexpr.universe_decl_expr option;
  fix_annot : Misctypes.lident option;
  fix_binders : local_binder_expr list;
  fix_body : constr_expr option;
  fix_type : constr_expr
}

(** Typing global fixpoints and cofixpoint_expr *)

(** Exported for Program *)
val interp_recursive :
  (* Misc arguments *)
  program_mode:bool -> cofix:bool ->
  (* Notations of the fixpoint / should that be folded in the previous argument? *)
  structured_fixpoint_expr list -> decl_notation list ->

  (* env / signature / univs / evar_map *)
  (Environ.env * EConstr.named_context * Univdecls.universe_decl * Evd.evar_map) *
  (* names / defs / types *)
  (Id.t list * Constr.constr option list * Constr.types list) *
  (* ctx per mutual def / implicits / struct annotations *)
  (EConstr.rel_context * Impargs.manual_explicitation list * int option) list

(** Exported for Funind *)

(** Extracting the semantical components out of the raw syntax of
   (co)fixpoints declarations *)

val extract_fixpoint_components : bool ->
  (fixpoint_expr * decl_notation list) list ->
    structured_fixpoint_expr list * decl_notation list

val extract_cofixpoint_components :
  (cofixpoint_expr * decl_notation list) list ->
    structured_fixpoint_expr list * decl_notation list

type recursive_preentry =
  Id.t list * constr option list * types list

val interp_fixpoint :
  cofix:bool ->
  structured_fixpoint_expr list -> decl_notation list ->
  recursive_preentry * Univdecls.universe_decl * UState.t *
  (EConstr.rel_context * Impargs.manual_implicits * int option) list

(** Registering fixpoints and cofixpoints in the environment *)
(** [Not used so far] *)
val declare_fixpoint :
  locality -> polymorphic ->
  recursive_preentry * Univdecls.universe_decl * UState.t *
  (Context.Rel.t * Impargs.manual_implicits * int option) list ->
  Proof_global.lemma_possible_guards -> decl_notation list -> unit

val declare_cofixpoint : locality -> polymorphic ->
  recursive_preentry * Univdecls.universe_decl * UState.t *
  (Context.Rel.t * Impargs.manual_implicits * int option) list ->
  decl_notation list -> unit

(** Very private function, do not use *)
val compute_possible_guardness_evidences :
  ('a, 'b) Context.Rel.pt * 'c * int option -> int list
