(* Display: produces a Notty image for the current viewport. *)

val render : view:View.t -> header:Row.t -> rows:Row.t list -> Notty.image
