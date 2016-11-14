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
  string ->
  ?attachments:Slack_api_j.attachments ->
  Slack_api_channel.t ->
  string ->
  unit response Lwt.t

val button : text:string -> url:string -> unit -> string

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
