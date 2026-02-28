(* Display: produces an ANSI string for the current viewport. *)

val render : view:View.t -> header:Row.t -> rows:Row.t list -> string
