open Lwt.Infix
module Store = Irmin_mem.KV (Markdown)
module Msg = Irmin_socket.Message (Markdown)

let info author = Irmin_unix.info ~author "update contents"

let sockets = ref []

let add_socket id socket =
  match List.assoc_opt id !sockets with
  | None -> sockets := (id, socket) :: !sockets
  | _ -> ()

let watcher store =
  Lwt.async (fun () ->
      Store.watch store (fun _ ->
          Store.get store [ "markdown" ] >>= fun s ->
          let v = Yojson.Safe.from_string s |> Msg.t_of_yojson in
          Lwt_list.iter_s
            (fun (id, socket) ->
              if v.user <> id then Dream.send s socket else Lwt.return ())
            !sockets)
      >|= fun _ -> ())

let run () =
  Store.Repo.v (Irmin_mem.config ()) >>= fun repo ->
  Store.master repo >>= fun store ->
  let update author msg =
    Store.set_exn ~info:(info author) store [ "markdown" ] msg
  in
  watcher store;
  let rec update_with_socket websocket =
    Dream.receive websocket >>= function
    | Some msg ->
        Dream.log "MSG: %s" msg;
        let v = Msg.t_of_yojson (Yojson.Safe.from_string msg) in
        add_socket v.user websocket;
        update v.user msg >>= fun () -> update_with_socket websocket
    | _ -> Lwt.return ()
  in
  Dream.serve @@ Dream.logger
  @@ Dream.router
       [
         Dream.get "/" (fun _ -> Dream.html Html.html);
         Dream.get "/static/**" (Dream.static "./static");
         Dream.get "/websocket" (fun _ ->
             Dream.websocket (fun websocket ->
                 Dream.log "Sockets: %i" (List.length !sockets);
                 update_with_socket websocket));
       ]
  @@ Dream.not_found

let () = Lwt_main.run (run ())
