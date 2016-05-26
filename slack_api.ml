(*
   Client for the Slack API (incomplete)

   https://api.slack.com/

   Publishing a Slack app with a bot works as follows:

   - create a Slack team for development purposes
   - create a Slack user in that team that will own the app
   - create a Slack app interactively, while logged in as this user
   - define a bot user for the app, which is a special kind of user
     that will be created into the app user's team when the app is
     installed. If the chosen name for the bot is already taken
     in the receiving team, then Slack modifies it slightly.

   For a user to use the app, the following must typically be done:

   1. "Add to Slack": enables the app and creates the bot user, which
      gets a team-wide access token and can do different things depending
      on the requested permissions. Not all team members may install apps,
      depending on their team's configuration.

   2. "Sign In With Slack": this creates or validates a mapping between a user
      of your product and a Slack user in a Slack team. It is only required
      if users need to access their app data outside of Slack.
*)

open Lwt
open Slack_api_t

let is_ok_response s =
  try (Slack_api_j.response_of_string s).ok
  with e ->
    Log.logf `Error "Malformed Slack response: %s\n%s"
      s (Log.string_of_exn e);
    false

let handle_error error_code =
  failwith ("Slack error " ^ error_code)

let parse_response string_of_x s =
  match is_ok_response s with
  | true -> string_of_x s
  | false -> handle_error (Slack_api_j.error_response_of_string s).error

let opt k f = function
  | Some v -> [k, f v]
  | None -> []

let app_auth_url ?state ~client_id ~scope ~redirect_uri () =
  Uri.with_query' (Uri.of_string "https://slack.com/oauth/authorize")
    (["client_id",    client_id;
      "scope",        scope;
      "redirect_uri", redirect_uri]
     @ opt "state" (fun s -> s) state)

let users_identity {Slack_api_t.access_token} =
  Util_http_client.post_form
    (Uri.of_string "https://slack.com/api/users.identity")
    ["token", access_token]
  >>= fun (_status, _headers, body) ->
  return (parse_response Slack_api_j.user_identity_response_of_string body)

let auth_test {Slack_api_t.access_token} =
  Util_http_client.post_form
    (Uri.of_string "https://slack.com/api/auth.test")
    ["token", access_token]
  >>= fun (_status, _headers, body) ->
  return (is_ok_response body)

let oauth_access ~client_id ~client_secret ~code ~redirect_uri =
  Util_http_client.post_form
    (Uri.of_string "https://slack.com/api/oauth.access")
    ["client_id",     client_id;
     "client_secret", client_secret;
     "code",          code;
     "redirect_uri",  redirect_uri]
  >>= fun (_status, _headers, body) ->
  return (parse_response Slack_api_j.auth_of_string body)

let im_open token slack_userid =
  Util_http_client.post_form
    (Uri.of_string "https://slack.com/api/im.open")
    ["token", token;
     "user",  Slack_api_userid.to_string slack_userid]
  >>= fun (_status, _headers, body) ->
  let open Slack_api_t in
  let resp = parse_response Slack_api_j.channel_response_of_string body in
  return resp.channel.slackchannel_id

let chat_post_message token channel text =
  Util_http_client.post_form
    (Uri.of_string "https://slack.com/api/chat.postMessage")
    ["token",   token;
     "channel", Slack_api_channel.to_string channel;
     "text",    text]

let button ~text ~url () =
  "<" ^ url ^ "|" ^ text ^ ">"


let rtm_start ?simple_latest ?no_unreads ?mpim_aware token =
  Util_http_client.post_form
    (Uri.of_string "https://slack.com/api/rtm.start")
    (List.flatten [
       ["token", token];
       opt "simple_latest" string_of_bool simple_latest;
       opt "no_unreads"    string_of_bool no_unreads;
       opt "mpim_aware"    string_of_bool mpim_aware;
     ])
  >>= fun (_status, _headers, body) ->
  return (parse_response Slack_api_j.rtm_start_resp_of_string body)
