(* View: the viewport state.

   Tracks everything needed to know *what* to display:
   - which row is at the top of the screen
   - where the cursor is
   - the current terminal dimensions

   All functions here are pure — they take a state and return a new state.
   No I/O, no rendering. *)

type t = {
  row_offset    : int;  (* index of the first visible row *)
  col_offset    : int;  
  cursor_row    : int;  (* cursor position is relative to the offset *)
  cursor_col   : int;  
  term_width    : int;  (* number of characters *)
  term_height   : int;  (* number of rows of height *)
  total_rows    : int;  (* total number of rows in the file, from the index *)
  total_cols : int;
}

let init ~term_width ~term_height ~total_rows ~total_cols = {
  row_offset = 0;
  col_offset = 0;
  cursor_row = 0;
  cursor_col = 0;
  term_width;
  term_height;
  total_rows;
  total_cols;
}

(* removing 2 visible rows 
 - the first for the sticky header row
 - the second for the status bar at the bottom
*)
let visible_rows t = t.term_height - 2

let scroll_down t =
  {t with row_offset = min (t.total_rows-1) (t.row_offset + 1)}

let scroll_up t =
  {t with row_offset = max 0 ( t.row_offset - 1)}

let scroll_right t =
  {t with col_offset = min (t.total_cols-1) (t.col_offset + 1)}

let scroll_left t =
  {t with col_offset = max 0 (t.col_offset - 1)}

let scroll_to_top t =
  {t with row_offset = 0}

let scroll_to_bottom t =
  {t with row_offset = max 0 (t.total_rows - (visible_rows t))}

let resize width height t =
  (* 
    keeping it simple to start, any resizing sets cursor back to home. 
    TODO-someday: update this to be more dynamic.
  *)
  { t with cursor_row = 0; cursor_col = 0;term_width = width; term_height = height }  

  
