module type Value = Protocol.Value

module type Websocket = Protocol.Websocket

module Message = Protocol.Message

module Make (V : Protocol.Value) (W : Protocol.Websocket) = struct
  module M = Protocol.Message (V)
  module Socket = W

  let create = Socket.create

  let send socket t =
    let serialise = M.yojson_of_t t |> Yojson.Safe.to_string in
    Socket.send socket serialise

  let on_message t f =
    Socket.on_message t (fun str ->
        f (M.t_of_yojson (Yojson.Safe.from_string str)))
end
