(*
   Client for the Slack API (incomplete)
*)

open Lwt

let optional k = function
  | Some v -> [k, v]
  | None -> []

let app_auth_url ?state ~client_id ~scope ~redirect_uri () =
  Uri.with_query' (Uri.of_string "https://slack.com/oauth/authorize")
    (["client_id",    client_id;
      "scope",        scope;
      "redirect_uri", redirect_uri]
     @ optional "state" state)

let users_identity {Slack_api_t.access_token} =
  Util_http_client.post_form
    (Uri.of_string "https://slack.com/api/users.identity")
    ["token", [access_token]]
  >>= fun (_status, _headers, body) ->
  return (Slack_api_j.user_identity_response_of_string body)

let auth_test {Slack_api_t.access_token} =
  Util_http_client.post_form
    (Uri.of_string "https://slack.com/api/auth.test")
    ["token", [access_token]]
  >>= fun (_status, _headers, body) ->
  let {Slack_api_t.ok} = Slack_api_j.response_of_string body in
  return ok

let oauth_access ~client_id ~client_secret ~code ~redirect_uri =
  Util_http_client.post_form
    (Uri.of_string "https://slack.com/api/oauth.access")
    ["client_id",     [client_id];
     "client_secret", [client_secret];
     "code",          [code];
     "redirect_uri",  [redirect_uri]]
  >>= fun (_status, _headers, body) ->
  return (Slack_api_j.auth_of_string body)

let im_open token slack_userid =
  Util_http_client.post_form
    (Uri.of_string "https://slack.com/api/im.open")
    ["token", [token];
     "user",  [Slack_api_userid.to_string slack_userid]]
  >>= fun (_status, _headers, body) ->
  let open Slack_api_t in
  return (Slack_api_j.channel_response_of_string body).channel.slackchannel_id

let chat_post_message token channel text =
  Util_http_client.post_form
    (Uri.of_string "https://slack.com/api/chat.postMessage")
    ["token",   [token];
     "channel", [Slack_api_channel.to_string channel];
     "text",    [text]]

let button ~text ~url () =
  "<" ^ url ^ "|" ^ text ^ ">"
