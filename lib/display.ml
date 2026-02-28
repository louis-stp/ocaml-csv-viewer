(* Display: pure rendering logic.

   Produces a string of ANSI escape codes representing the full screen.
   The caller (app.ml) writes this string to stdout in one shot to avoid
   flickering.

   ANSI basics used here:
   - \027[{row};{col}H  move cursor to position (1-indexed)
   - \027[0m            reset all attributes
   - \027[1m            bold
   - \027[7m            reverse video (swap fg/bg, used for cursor row)
   - \027[3{n}m         set foreground colour (0-7)
   - \027[4{n}m         set background colour (0-7) *)

let reset  = "\027[0m"
let bold   = "\027[1m"
let reverse = "\027[7m"

let move_to row col = Printf.sprintf "\027[%d;%dH" row col

(* Truncate or pad a string to exactly [width] characters. *)
let fit_string s width =
  let len = String.length s in
  if len >= width then String.sub s 0 width
  else s ^ String.make (width - len) ' '

(* Compute the display width for each column based on visible rows.
   Width = min(max cell length in that column, max_col_width). *)
let compute_col_widths ~max_col_width (rows : Row.t list) : int list =
  ignore (max_col_width, rows);
  failwith "todo"

(* Render a single row as a string, with cells fitted to col_widths.
   [attr] is an ANSI prefix string for styling (e.g. bold, reverse). *)
let render_row ~col_widths ~col_offset ~attr (row : Row.t) : string =
  ignore (col_widths, col_offset, attr, row);
  failwith "todo"

(* Render the status bar at the bottom of the screen. *)
let render_status_bar ~(view : View.t) : string =
  ignore view;
  failwith "todo"

(* Produce the full screen as a single ANSI string.
   Clears the screen, renders the header, data rows, and status bar. *)
let render ~(view : View.t) ~(header : Row.t) ~(rows : Row.t list) : string =
  ignore (view, header, rows, render_row, render_status_bar,
          compute_col_widths, move_to, reset, bold, reverse, fit_string);
  failwith "todo"
