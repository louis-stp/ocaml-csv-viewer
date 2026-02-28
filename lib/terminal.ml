(* Terminal: low-level terminal control.

   Three responsibilities:
   - Raw mode: disable line buffering and echo so keypresses are read
     immediately without the user pressing enter
   - Terminal size: query current dimensions in character cells
   - Key reading: read and parse keypresses including arrow key escape sequences *)

(* Enter raw mode. Returns the original attributes to be passed to teardown. *)
let setup () : Unix.terminal_io =
  let orig = Unix.tcgetattr Unix.stdin in
  Unix.tcsetattr Unix.stdin Unix.TCSAFLUSH { orig with
    Unix.c_icanon = false;
    Unix.c_echo   = false;
    Unix.c_vmin   = 1;
    Unix.c_vtime  = 0;
  };
  orig

(* Restore original terminal attributes. *)
let teardown (orig : Unix.terminal_io) : unit =
  Unix.tcsetattr Unix.stdin Unix.TCSAFLUSH orig

(* Query terminal size via stty. Returns (width, height). *)
let size () : int * int =
  let ic = Unix.open_process_in "stty size 2>/dev/null" in
  let line = try input_line ic with End_of_file -> "24 80" in
  ignore (Unix.close_process_in ic);
  match String.split_on_char ' ' line with
  | [rows; cols] -> (int_of_string cols, int_of_string rows)
  | _            -> (80, 24)

type key =
  | Char of char
  | Arrow of [`Up | `Down | `Left | `Right]
  | Enter
  | Escape
  | Unknown

(* Read one keypress. Blocks until input is available.
   Arrow keys send a 3-byte escape sequence: ESC [ A/B/C/D. *)
let read_key () : key =
  let read_char () =
    let buf = Bytes.create 1 in
    ignore (Unix.read Unix.stdin buf 0 1);
    Bytes.get buf 0
  in
  match read_char () with
  | '\027' ->
    let buf = Bytes.create 2 in
    let n = Unix.read Unix.stdin buf 0 2 in
    if n = 2 && Bytes.get buf 0 = '[' then
      match Bytes.get buf 1 with
      | 'A' -> Arrow `Up
      | 'B' -> Arrow `Down
      | 'C' -> Arrow `Right
      | 'D' -> Arrow `Left
      | _   -> Unknown
    else Escape
  | '\r' | '\n' -> Enter
  | c           -> Char c
