(* Reader: responsible for all file I/O.

   Two jobs:
   1. Scan the file once on open to build the row index (byte offsets).
   2. Seek to any row and parse just enough rows to fill the viewport.

   Uses the `Csv` library for parsing, and plain `in_channel` for seeking.
   Note: `pos_in` and `seek_in` let us jump to arbitrary byte positions. *)

type line_parser_state =
| Normal
| InQuotes

let build_index (ic : in_channel) : Index.t =
  let rec line_parser ~parser_state ~indices =
    let continue = line_parser ~parser_state ~indices in
    match parser_state, input_char ic with
    | Normal, '"' -> line_parser ~parser_state:InQuotes ~indices
    | Normal, '\n' -> line_parser ~parser_state ~indices:(pos_in ic :: indices)
    | Normal, _ -> continue
    | InQuotes, '"' -> line_parser ~parser_state:Normal ~indices
    | InQuotes, _ -> continue
    | exception End_of_file -> indices
  in line_parser ~parser_state:Normal ~indices:[0] |> List.rev |> Array.of_list


let fetch_rows (ic : in_channel) (idx : Index.t) ~(row_offset : int) ~(count : int) : Row.t list =
  seek_in ic idx.(row_offset);
  let csv = Csv.of_channel ic in
  let rec acc ~rows_remaining ~rows =
    if rows_remaining = 0 then List.rev rows else
      match Csv.next csv with
      | row -> acc ~rows_remaining:(rows_remaining - 1) ~rows:(row :: rows)
      | exception End_of_file -> List.rev rows
    in acc ~rows_remaining:count ~rows:[]