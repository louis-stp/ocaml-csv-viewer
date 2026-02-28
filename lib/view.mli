(* View: viewport state and pure update functions. *)

type t = {
  row_offset  : int;
  col_offset  : int;
  cursor_row  : int;
  cursor_col  : int;
  term_width  : int;
  term_height : int;
  total_rows  : int;
  total_cols : int;
}

val init : term_width:int -> term_height:int -> total_rows:int -> total_cols:int -> t

(* How many data rows fit on screen at once. *)
val visible_rows : t -> int

val scroll_down      : t -> t
val scroll_up        : t -> t
val scroll_left      : t -> t
val scroll_right     : t -> t
val scroll_to_top    : t -> t
val scroll_to_bottom : t -> t
val resize           : int -> int -> t -> t
