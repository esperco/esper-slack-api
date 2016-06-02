(*
   Slack documentation for scopes is incomplete, confusing and possibly wrong.
   Good luck!
   https://api.slack.com/docs/oauth-scopes
*)

let oauth_scopes_to_api_methods = [
  "users:read";
  "channels:write";
  "channels:history";
  "channels:read";
  "chat:write:bot";
  "chat:write:user";
  "dnd:write";
  "dnd:read";
  "emoji:read";
  "files:write:user";
  "files:read";
  "groups:write";
  "groups:history";
  "groups:read";
  "im:write";
  "im:history";
  "im:read";
  "mpim:write";
  "mpim:history";
  "mpim:read";
  "pins:write";
  "pins:read";
  "reactions:write";
  "reactions:read";
  "reminders:write";
  "reminders:read";
  "search:read";
  "stars:write";
  "stars:read";
  "team:read";
  "usergroups:write";
  "usergroups:read";
  "identity.basic";
  "users:write";
]

let slack_app_scopes = [
  "incoming-webhook";
  "commands";
  "bot";
]

let special_scopes = [
  "identify";
  "client";
  "admin";
]

let deprecated_scopes = [
  "read";
  "post";
]

let unlisted_scopes = [
  "identity.team";
]

let combine scopes =
  String.concat "," scopes
