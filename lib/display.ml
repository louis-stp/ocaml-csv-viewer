(* Display: pure rendering logic.

   Takes the current view state and the rows that are currently visible,
   and produces a Notty image to hand to the terminal.

   Responsibilities:
   - Compute column widths from the visible rows (capped at max_col_width)
   - Render the header row with distinct styling
   - Render each data row, highlighting the cursor row
   - Render a status bar at the bottom (row position, file info, keybindings) *)

open Notty
open Notty.Infix

let compute_col_widths ~max_col_width (rows : Row.t list) : int list =
  ignore (max_col_width, rows);
  failwith "todo"

let render_row ~col_widths ~attr (row : Row.t) : image =
  ignore (col_widths, attr, row);
  failwith "todo"

let render_status_bar ~(view : View.t) : image =
  ignore view;
  failwith "todo"

let render ~(view : View.t) ~(header : Row.t) ~(rows : Row.t list) : image =
  ignore (view, header, rows, render_row, render_status_bar, compute_col_widths, (<->));
  failwith "todo"
