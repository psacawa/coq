(************************************************************************)
(*  v      *   The Coq Proof Assistant  /  The Coq Development Team     *)
(* <O___,, *   INRIA - CNRS - LIX - LRI - PPS - Copyright 1999-2017     *)
(*   \VV/  **************************************************************)
(*    //   *      This file is distributed under the terms of the       *)
(*         *       GNU Lesser General Public License Version 2.1        *)
(************************************************************************)
open Names
open Constr
open Cbytecodes

(** This file defines the lambda code for the bytecode compiler. It has been
extracted from Clambda.ml because of the retroknowledge architecture. *)

type uint =
  | UintVal of Uint31.t
  | UintDigits of lambda array
  | UintDecomp of lambda

and lambda =
  | Lrel          of Name.t * int
  | Lvar          of Id.t
  | Lprod         of lambda * lambda
  | Llam          of Name.t array * lambda
  | Llet          of Name.t * lambda * lambda
  | Lapp          of lambda * lambda array
  | Lconst        of pconstant
  | Lprim         of pconstant * int (* arity *) * instruction * lambda array
  | Lcase         of case_info * reloc_table * lambda * lambda * lam_branches
  | Lfix          of (int array * int) * fix_decl
  | Lcofix        of int * fix_decl
  | Lmakeblock    of int * lambda array
  | Lval          of structured_constant
  | Lsort         of Sorts.t
  | Lind          of pinductive
  | Lproj         of int * Constant.t * lambda
  | Luint         of uint

and lam_branches =
  { constant_branches : lambda array;
    nonconstant_branches : (Name.t array * lambda) array }

and fix_decl =  Name.t array * lambda array * lambda array
