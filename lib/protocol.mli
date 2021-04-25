module type Value = sig
  type t [@@deriving yojson]

  include Irmin.Contents.S with type t := t
end

module Message : functor (V : Value) -> sig
  type t = { user : string; value : V.t } [@@deriving yojson]
end

module type Websocket = sig
  type t

  val create : ?protocols:string list -> string -> t

  val send : t -> string -> unit

  val on_message : t -> (string -> unit) -> unit
end
