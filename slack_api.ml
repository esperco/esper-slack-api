(*
   Client for the Slack API (incomplete).
   See slack_api.mli
*)

open Lwt
open Log
open Slack_api_t
open Util_url.Op

type 'a response = [
  | `OK of 'a
  | `Error of string
]

let extract_error s =
  try
    if (Slack_api_j.response_of_string s).ok then
      None
    else
      Some (Slack_api_j.error_response_of_string s).error
  with e ->
    logf `Error "Malformed Slack response: %s\n%s"
      s (string_of_exn e);
    Some ("Malformed Slack response: " ^ s)

let parse_response string_of_x s : _ response =
  match extract_error s with
  | None -> `OK (string_of_x s)
  | Some err ->
      logf `Error "Slack error: %s" s;
      `Error err

let is_ok_response s = parse_response (fun s -> ()) s

let opt k f = function
  | Some v -> [k, f v]
  | None -> []

let app_auth_url ?state ?team ~client_id ~scope ~redirect_uri () =
  Uri.with_query' (Uri.of_string "https://slack.com/oauth/authorize")
    (["client_id",    client_id;
      "scope",        scope;
      "redirect_uri", redirect_uri]
     @ opt "state" (fun s -> s) state
     @ opt "team" Slack_api_teamid.to_string team)

let users_identity {Slack_api_t.access_token} =
  Util_http_client.post_form
    (Uri.of_string "https://slack.com/api/users.identity")
    ["token", access_token]
  >>= fun (status, headers, body) ->
  return (parse_response Slack_api_j.user_identity_response_of_string body)

let auth_test access_token =
  Util_http_client.post_form
    (Uri.of_string "https://slack.com/api/auth.test")
    ["token", access_token]
  >>= fun (status, headers, body) ->
  return (is_ok_response body)

let oauth_access ~client_id ~client_secret ~code ~redirect_uri =
  Util_http_client.post_form
    (Uri.of_string "https://slack.com/api/oauth.access")
    ["client_id",     client_id;
     "client_secret", client_secret;
     "code",          code;
     "redirect_uri",  redirect_uri]
  >>= fun (status, headers, body) ->
  return (parse_response Slack_api_j.auth_of_string body)

let im_open token slack_userid =
  Util_http_client.post_form
    (Uri.of_string "https://slack.com/api/im.open")
    ["token", token;
     "user",  Slack_api_userid.to_string slack_userid]
  >>= fun (status, headers, body) ->
  let open Slack_api_t in
  match parse_response Slack_api_j.channel_response_of_string body with
  | `OK resp ->
      return (`OK resp.channel.slackchannel_id)
  | `Error err ->
      return (`Error err)

let chat_post_message ?attachments ?text token channel =
  let string_of_attachments x = Slack_api_j.string_of_attachments x in
  let opt_text =
    match text with
    | None -> []
    | Some s -> ["text", [s]]
  in
  Util_http_client.post_form'
    (Uri.of_string "https://slack.com/api/chat.postMessage")
    (("attachments", string_of_attachments, attachments) @^@
     ["token",   [token];
      "channel", [Slack_api_channel.to_string channel]
     ] @ opt_text)
  >>= fun (status, headers, body) ->
  return (is_ok_response body)

let button ~text ~url () =
  "<" ^ url ^ "|" ^ text ^ ">"

let reactions_add token channel ts reaction =
  Util_http_client.post_form
    (Uri.of_string "https://slack.com/api/reactions.add")
    ["token",     token;
     "channel",   Slack_api_channel.to_string channel;
     "timestamp", Slack_api_ts.to_string ts;
     "name",      reaction]
  >>= fun (status, headers, body) ->
  return (is_ok_response body)

let reactions_remove token channel ts reaction =
  Util_http_client.post_form
    (Uri.of_string "https://slack.com/api/reactions.remove")
    ["token",     token;
     "channel",   Slack_api_channel.to_string channel;
     "timestamp", Slack_api_ts.to_string ts;
     "name",      reaction]
  >>= fun (status, headers, body) ->
  return (is_ok_response body)

let rtm_start ?simple_latest ?no_unreads ?mpim_aware token =
  Util_http_client.post_form
    (Uri.of_string "https://slack.com/api/rtm.start")
    (List.flatten [
       ["token", token];
       opt "simple_latest" string_of_bool simple_latest;
       opt "no_unreads"    string_of_bool no_unreads;
       opt "mpim_aware"    string_of_bool mpim_aware;
     ])
  >>= fun (status, headers, body) ->
  return (parse_response Slack_api_j.rtm_start_resp_of_string body)

let get_event_type json_string =
  try
    let x = Slack_api_j.type_only_of_string json_string in
    Some x.Slack_api_j.type_
  with _ ->
    None

let event_of_string s : Slack_api_t.event =
  match get_event_type s with
  | None ->
      invalid_arg ("Slack_api.event_of_string: " ^ s)
  | Some type_ ->
      match type_ with
      | "hello" -> `Hello
      | "message" ->
          `Message (Slack_api_j.message_of_string s)
      | "reaction_added" ->
          `Reaction_added (Slack_api_j.reaction_added_of_string s)
      | "reaction_removed" ->
          `Reaction_removed (Slack_api_j.reaction_removed_of_string s)
      | "user_typing" ->
          `User_typing (Slack_api_j.user_typing_of_string s)
      | _ ->
          `Other s
