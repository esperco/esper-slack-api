(*
   Wrapper to support objects of type "embedded item" whose type
   is indicated by a `type` field among the other fields.
*)

type t = Slack_api_embedded_t.item

let get_type json_string =
  try
    let x = Slack_api_embedded_j.type_only_of_string json_string in
    Some x.Slack_api_embedded_j.type_
  with _ ->
    None

let read_t ls lb : t =
  let json_ast = Yojson.Basic.read_json ls lb in
  let json_string = Yojson.Basic.to_string json_ast in
  match get_type json_string with
  | Some "message" ->
      `Message (Slack_api_embedded_j.message_of_string json_string)
  | _ ->
      `Other json_string

let write_t ob (x : t) =
  match x with
  | `Message x -> Slack_api_embedded_j.write_message ob x
  | `Other s -> Bi_outbuf.add_string ob s

let validate_t _ _ = None
