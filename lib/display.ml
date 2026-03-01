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

let v_sep = "│"

let move_to row col = Printf.sprintf "\027[%d;%dH" row col

(* Truncate or pad a string to exactly [width] characters. *)
let fit_string ~s ~width =
  let len = String.length s in
  if len >= width then 
   String.sub s 0 (width-1) ^ ">"
  else s ^ String.make (width - len) ' '

(* Compute the display width for each column based on visible rows.
   Width = min(max cell length in that column, max_col_width). *)
let compute_col_widths ~max_col_width (rows : Row.t list) : int list =
  let transpose = function
  | [] -> []
  | hd :: _ as rows -> List.init (List.length hd) (fun i ->
    List.map (fun row ->
      match List.nth_opt row i with
      | Some v -> v
      | None -> 0
      ) rows
    ) in
  let cell_widths = rows |> List.map (List.map String.length) in
  cell_widths |> transpose |> List.map (List.fold_left max 0) |> List.map (min max_col_width)


(* Render a single row as a string, with cells fitted to col_widths.
   [attr] is an ANSI prefix string for styling (e.g. bold, reverse). *)
let render_row ~(col_widths: int list) ~(col_offset: int) ~(local_row_num: int) ~(view: View.t) (row : Row.t) : string =
  let cells_fitted = List.filteri (fun i _ -> i >= col_offset) row 
  |> List.mapi (fun i s -> fit_string ~s ~width:(List.nth col_widths i)) in
  let rec build_row_styled ~raw_string ~num_chars ~remaining_cells ~local_col_num = 
    let is_cursor = (local_col_num = view.cursor_col && local_row_num = view.cursor_row) in
    let style = if is_cursor then reverse else reset in
    match remaining_cells with
    | [] -> raw_string ^ reset ^ String.make (view.term_width - num_chars) ' '
    | hd :: tl -> 
      let col_width = (List.nth col_widths (col_offset + local_col_num)) + 1 in (* the +1 is for the vertical seperator*)
      let new_row_width = num_chars + col_width in
      let concat_styled_text text = raw_string ^ v_sep ^ style ^ text ^ reset in
      if new_row_width > view.term_width then
        let hd = String.sub hd 0 ((String.length hd)-(new_row_width - view.term_width)) in
        concat_styled_text hd
      else
        build_row_styled ~raw_string:(concat_styled_text hd) ~num_chars:(num_chars+col_width) ~remaining_cells:tl ~local_col_num:(local_col_num+1)
      in
      build_row_styled ~raw_string:v_sep ~num_chars:0 ~remaining_cells:cells_fitted ~local_col_num:0



(* Render the status bar at the bottom of the screen. *)
let render_status_bar ~(view : View.t) : string =
  let bg_blue = "\027[44m" in
  bg_blue ^ String.make view.term_width ' ' ^ reset

(* Produce the full screen as a single ANSI string.
   Clears the screen, renders the header, data rows, and status bar. *)
let render ~(view : View.t) ~(header : Row.t) ~(rows : Row.t list) : string =
  let col_widths = compute_col_widths ~max_col_width:30 (header :: rows) in
  let clear = "\027[2J\027[H" in
  let header_str = move_to 1 1 ^ bold ^ render_row ~col_widths ~col_offset:view.View.col_offset ~local_row_num:(-1) ~view header in
  let rows_str =
    List.mapi (fun i row ->
      move_to (i + 2) 1 ^ render_row ~col_widths ~col_offset:view.View.col_offset ~local_row_num:i ~view row
    ) rows
    |> String.concat ""
  in
  let status_str = move_to view.View.term_height 1 ^ render_status_bar ~view in
  clear ^ header_str ^ rows_str ^ status_str
