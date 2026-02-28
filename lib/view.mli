(* View: viewport state and pure update functions. *)

type t = {
  row_offset  : int;
  cursor      : int;
  term_width  : int;
  term_height : int;
  total_rows  : int;
  max_col_width : int;
}

val init : term_width:int -> term_height:int -> total_rows:int -> max_col_width:int -> t

(* How many data rows fit on screen at once. *)
val visible_rows : t -> int

val scroll_down : t -> t
val scroll_up   : t -> t
val resize      : int -> int -> t -> t
