(* Reader: file I/O, index building, and row fetching. *)

(* Scan the file and return an index of byte offsets, one per row. *)
val build_index : in_channel -> Index.t

(* Fetch [count] rows starting from [row_offset] in the index. *)
val fetch_rows : in_channel -> Index.t -> row_offset:int -> count:int -> Row.t list
