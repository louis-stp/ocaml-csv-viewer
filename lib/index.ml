(* Index: the row offset index built from a single scan of the file.
   index.(i) is the byte offset in the file where row i begins. *)

type t = int array

let length = Array.length
