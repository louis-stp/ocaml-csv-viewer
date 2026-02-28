(* App: application logic and CLI entry point. *)

open Cmdliner

let default_max_col_width = 30

let enter_alt_screen = "\027[?1049h\027[?25l"  (* alt screen + hide cursor *)
let exit_alt_screen  = "\027[?1049l\027[?25h"  (* restore screen + show cursor *)

let run filename =
  let ic = open_in filename in
  let idx = Reader.build_index ic in
  let total_rows = Index.length idx in
  let orig = Terminal.setup () in
  print_string enter_alt_screen;
  flush stdout;
  let (tw, th) = Terminal.size () in
  let header = List.nth (Reader.fetch_rows ic idx ~row_offset:0 ~count:1) 0 in
  let total_cols = List.length header in
  let view = View.init ~term_width:tw ~term_height:th ~total_rows ~total_cols in
  let rec loop view =
    let rows = Reader.fetch_rows ic idx ~row_offset:view.View.row_offset ~count:(View.visible_rows view) in
    let screen = Display.render ~view ~header ~rows in
    print_string screen;
    flush stdout;
    match Terminal.read_key () with
    | Terminal.Char 'q' ->
      print_string exit_alt_screen;
      flush stdout;
      Terminal.teardown orig
    | Terminal.Char 'j'
    | Terminal.Arrow `Down    -> loop (View.scroll_down view)
    | Terminal.Char 'k'
    | Terminal.Arrow `Up      -> loop (View.scroll_up view)
    | Terminal.Char 'h'
    | Terminal.Arrow `Left    -> loop (View.scroll_left view)
    | Terminal.Char 'l'
    | Terminal.Arrow `Right   -> loop (View.scroll_right view)
    | Terminal.Char 'g'       -> loop (View.scroll_to_top view)
    | Terminal.Char 'G'       -> loop (View.scroll_to_bottom view)
    | _                       -> loop view
  in
  loop view;
  ignore default_max_col_width

let filename_arg =
  Arg.(required & pos 0 (some string) None & info [] ~docv:"FILE" ~doc:"CSV file to view.")

let cmd =
  Cmd.v (Cmd.info "csv-viewer" ~doc:"View CSV files in the terminal.")
    Term.(const run $ filename_arg)

let main () = exit (Cmd.eval cmd)
