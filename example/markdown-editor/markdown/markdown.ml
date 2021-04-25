type t = string [@@deriving yojson]

let t = Irmin.Contents.String.t

let merge = Irmin.Contents.String.merge
