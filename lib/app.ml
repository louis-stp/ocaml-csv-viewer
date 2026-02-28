(* App: application logic and CLI entry point.

   `main` parses CLI args and kicks off the event loop.
   The loop itself is a tail-recursive function carrying View.t as its state:
   render → block on keypress → update view → repeat. *)

open Notty_unix
open Cmdliner

let default_max_col_width = 30

let run filename =
  let ic = open_in filename in
  let idx = Reader.build_index ic in
  let total_rows = Index.length idx in
  let term = Term.create () in
  let (tw, th) = Term.size term in
  let view = View.init ~term_width:tw ~term_height:th ~total_rows ~max_col_width:default_max_col_width in
  let header = List.nth (Reader.fetch_rows ic idx ~row_offset:0 ~count:1) 0 in
  let rec loop view =
    let rows = Reader.fetch_rows ic idx ~row_offset:view.View.row_offset ~count:(View.visible_rows view) in
    let image = Display.render ~view ~header ~rows in
    Term.image term image;
    match Term.event term with
    | `Key (`ASCII 'q', _) -> Term.release term
    | `Key (`ASCII 'j', _) -> loop (View.scroll_down view)
    | `Key (`ASCII 'k', _) -> loop (View.scroll_up view)
    | `Resize (w, h)        -> loop (View.resize w h view)
    | _                     -> loop view
  in
  loop view

let filename_arg =
  Arg.(required & pos 0 (some string) None & info [] ~docv:"FILE" ~doc:"CSV file to view.")

let cmd =
  Cmd.v (Cmd.info "csv-viewer" ~doc:"View CSV files in the terminal.")
    Term.(const run $ filename_arg)

let main () = exit (Cmd.eval cmd)
