(*
   Client for the Slack API (incomplete)

   https://api.slack.com/

   For Esper, see setup instructions in `wolverine/slack/README.md`
*)

type 'a response = [ `OK of 'a | `Error of string ]

val app_auth_url :
  ?state:string ->
  ?team:Slack_api_teamid.t ->
  client_id:string ->
  scope:string ->
  redirect_uri:string -> unit -> Uri.t

val users_identity :
  Slack_api_t.auth ->
  Slack_api_j.user_identity_response response Lwt.t

val auth_test : string -> unit response Lwt.t

val oauth_access :
  client_id:string ->
  client_secret:string ->
  code:string ->
  redirect_uri:string ->
  Slack_api_j.auth response Lwt.t

val im_open :
  string ->
  Slack_api_userid.t ->
  Slack_api_t.slack_channel response Lwt.t

val chat_post_message :
  ?attachments: Slack_api_j.attachments ->
  ?text: string ->
  string ->
  Slack_api_channel.t ->
  Slack_api_t.post_message_response response Lwt.t

val reactions_add :
  string ->
  Slack_api_channel.t ->
  Slack_api_ts.t -> string -> unit response Lwt.t

val reactions_remove :
  string ->
  Slack_api_channel.t ->
  Slack_api_ts.t ->
  string ->
  unit response Lwt.t

val rtm_start :
  ?simple_latest:bool ->
  ?no_unreads:bool ->
  ?mpim_aware:bool -> string -> Slack_api_j.rtm_start_resp response Lwt.t

val event_of_string : string -> Slack_api_t.event
