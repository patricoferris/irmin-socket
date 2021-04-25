open Brr_io

type t = Websocket.t

let create ?protocols uri =
  Websocket.create
    ?protocols:(Option.map (List.map Jstr.of_string) protocols)
    (Jstr.of_string uri)

let send socket t = Websocket.send_string socket (Jstr.of_string t)

let on_message t f =
  let message msg =
    Brr.Ev.as_type msg |> Message.Ev.data |> Jstr.to_string |> f
  in
  Brr.Ev.listen Message.Ev.message message
    (Brr.Ev.target_of_jv (Websocket.to_jv t))
