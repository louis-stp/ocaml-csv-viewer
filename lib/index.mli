(* The row offset index: index.(i) is the byte offset of row i in the file. *)

type t = int array

val length : t -> int
