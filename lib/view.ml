(* View: the viewport state.

   Tracks everything needed to know *what* to display:
   - which row is at the top of the screen
   - where the cursor is
   - the current terminal dimensions

   All functions here are pure — they take a state and return a new state.
   No I/O, no rendering. *)

type t = {
  row_offset    : int;  (* index of the first visible row *)
  cursor        : int;  (* cursor position relative to row_offset *)
  term_width    : int;
  term_height   : int;
  total_rows    : int;  (* total number of rows in the file, from the index *)
  max_col_width : int;
}

let init ~term_width ~term_height ~total_rows ~max_col_width = {
  row_offset = 0;
  cursor = 0;
  term_width;
  term_height;
  total_rows;
  max_col_width;
}

let visible_rows t = t.term_height - 2

let scroll_down _t =
  failwith "todo"

let scroll_up _t =
  failwith "todo"

let resize _w _h _t =
  failwith "todo"
