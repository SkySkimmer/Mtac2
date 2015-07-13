(** This module define the parser the proof mode MProof for Mtac2.

    This parser is trivial: a MProof command is simply a toplevel
    Gallina term.
*)

(*i camlp4deps: "grammar/grammar.cma" i*)
open Pcoq

(** New parser entry proof_mode *)
let mproof_mode : Vernacexpr.vernac_expr Gram.entry =
  Gram.entry_create "vernac:mproof_command"

 (** Create a new generic type of argument:
    force to associate unique ML types at each of the three levels
    (uninterpreted (raw), globalized and interpreted) *)
let wit_mproof_instr : (Mtac2Instr.mproof_instr, Util.Empty.t, Util.Empty.t) Genarg.genarg_type =
  Genarg.create_arg None "mproof_instr"

(** rawwit : Projection on the raw type constructor *)
let mproof_instr : Mtac2Instr.mproof_instr Gram.entry =
  Pcoq.create_generic_entry "mproof_instr" (Genarg.rawwit wit_mproof_instr)

(** classifier for classify the new parser entry
    * VtProofStep indicates that the type of the command
      is a step in the proof, and the following boolean
      indicates that if this step is parallelized or not.
    * VtLater indicates that the command doesn't alters the
      parser and can be executed later.
    To create a vernac entry we need to classify this one.
    A classifier is a function that returns an expression
    of type vernac_classification
*)
(** Create a new vernac command classified by "classify_mproof_instr"
    - the "-" indicates that the entry parsed doesn't have to begin with
      a particular string.
    - To create a vernac entry we need to classify this one.
      A classifier is a function that returns an expression
      of type vernac_classification
*)
VERNAC mproof_mode EXTEND MProofInstr
  [ - mproof_instr(instr) ] => [ Vernacexpr.VtProofStep false, Vernacexpr.VtLater ] ->
  [ () ]
END

(** Grammar extension :

*)
GEXTEND Gram
GLOBAL: mproof_instr;
  mproof_instr :
    [[ c=Pcoq.Constr.operconstr ; "." -> Run c ]];
END