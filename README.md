Developing and testing our Slack app
====================================

Teams, users, apps
------------------

Warning: do not confuse apps that we installed for our team as simple
users of Slack with the apps that we build and publish for Slack
users. We're concerned with the latter.

The official documentation and everything for building Slack apps is at

  https://api.slack.com/

Our Slack apps are managed by the Slack team `esper-dev`.
It is different (why?) from the Slack team we use as regular chat
users which is `espertech`.

This team, `esper-dev`, owns:
* the production app
* one development app per developer

User `esper-engineer` (`engineer@esper.com`) should be the owner
or at least a collaborator on each of these apps, in order to
make it easy for new developers to join.

Once logged-in as `esper-engineer` in `esper-dev`, the list of apps
that we manage is under (Your Apps)[https://api.slack.com/apps].

Each app is created manually from a web browser and consists in the
specification of name, logo, and URLs. All code is managed and run by
Esper over HTTPS and Websockets. No code is uploaded to Slack.

Links, buttons, notifications
-----------------------------

A bot can post messages that contain:

* links: any external links that will open a browser window or tab.
* buttons: can be created as attachments to Slack messages posted by a
  bot. Clicking on them results in Slack making an HTTP call to the
  URL registered with the app (see Interactive Messages setup).

Additionally, the bot can communicate with Slack using a websocket.
A websocket is a permanent, two-way connection maintained by the
client. Esper runs a service that maintains websocket connections for
each Slack team. This is what allows us receive certain notifications
such as when a user posts a message or when a user is typing. This is
provided by Slack's RTM API.

Online app setup
----------------

### Features > Interactive Messages

Request URL:
* prod: `https://app.esper.com/api/slack/message-action`
* dev: `https://beta.esper.com:80XX/api/slack/message-action`

Each developer has their own 80XX port. See wolverine setup.

This is used to receive button clicks.

Only one such URL can be configured per Slack app, this is why each
developer needs to configure their own app.

### Features > Bot User

Default username: `@esper` or `@esper-XXXXX` to avoid confusion between apps

This is the name of the private channel between the Esper bot and the
user.

### Features > OAuth & Permissions

Redirect URLs:

  * prod: `https://app.esper.com/api/slack/authorized`
  * dev: `https://beta.esper.com:80XX/api/slack/authorized`

Permission scopes (selected manually from dropdown):

  * `bot`
  * `chat:write:bot`
  * `im:history`
  * `im:read`
  * `im:write`
