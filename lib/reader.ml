(* Reader: responsible for all file I/O.

   Two jobs:
   1. Scan the file once on open to build the row index (byte offsets).
   2. Seek to any row and parse just enough rows to fill the viewport.

   Uses the `Csv` library for parsing, and plain `in_channel` for seeking.
   Note: `pos_in` and `seek_in` let us jump to arbitrary byte positions. *)

let build_index (_ic : in_channel) : Index.t =
  failwith "todo"

let fetch_rows (_ic : in_channel) (_idx : Index.t) ~(row_offset : int) ~(count : int) : Row.t list =
  ignore (row_offset, count);
  failwith "todo"
