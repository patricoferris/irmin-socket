open Mithril
open Brr
module Socket = Irmin_socket.Make (Markdown) (Irmin_socket_brr)

let math = Jv.get Jv.global "Math"

let id =
  let random = Jv.get math "random" in
  Jv.apply random [||] |> Jv.to_float |> Jstr.of_float |> Jstr.to_string

let socket = Socket.create "ws://localhost:8080/websocket"

let markdown, update =
  let content = ref "" in
  let update t = content := t in
  (content, update)

let updating = ref false

let markdown_viewer =
  let view _ =
    M.v "div.markdown"
      ~children:(`Vnodes [ M.trust Omd.(of_string !markdown |> to_html) ])
  in
  Component.v view

let text_editor =
  let _ =
    Socket.on_message socket (fun t ->
        Brr.Console.log [ Jstr.of_string "Received"; Jstr.of_string t.value ];
        update t.value;
        ( match Document.find_el_by_id G.document (Jstr.of_string "editor") with
        | Some el -> El.set_children el [ El.txt (Jstr.of_string t.value) ]
        | None -> () );
        M.redraw ())
  in
  let key_press e =
    let open Ev in
    let event = of_jv e in
    if !updating = true then Ev.prevent_default event
    else
      let target = Ev.target event |> Ev.target_to_jv in
      match Jv.find target "innerText" with
      | Some t ->
          let s = Jv.to_string t in
          update s;
          Socket.send socket { user = id; value = !markdown }
      | None -> ()
  in
  let attr =
    Attr.(
      v
        [|
          attr "contenteditable" @@ Jv.of_bool true;
          Attr.attr "onkeyup" (Jv.repr key_press);
        |])
  in
  let view _ = M.v ~attr "div.text-editor#editor" in
  Component.v view

let main =
  let title = M.(v "h1.title" ~children:(`String "Omd-itor")) in
  let view _ =
    let body =
      M.(
        v "main"
          ~children:(`Vnodes [ v_comp text_editor; v_comp markdown_viewer ]))
    in
    M.(v "div.content" ~children:(`Vnodes [ title; body ]))
  in
  Component.v view

let () =
  let body = Document.body G.document in
  M.mount body main
