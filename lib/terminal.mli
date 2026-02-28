(* Terminal: raw mode, terminal size, and key reading. *)

val setup    : unit -> Unix.terminal_io
val teardown : Unix.terminal_io -> unit
val size     : unit -> int * int  (* (width, height) in characters *)

type key =
  | Char of char
  | Arrow of [`Up | `Down | `Left | `Right]
  | Enter
  | Escape
  | Unknown

val read_key : unit -> key
