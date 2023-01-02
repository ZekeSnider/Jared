# REST API

If enabled, Jared exposes a webserver on the port `3005` by default. You can configure this port in the `~/Library/Application Support/Jared/config.json` file under the `webserver.port` property.

## `POST /message` Endpoint

Send iMessage messages to any Person or Group. You will receive a `200 OK` status code if Jared successfully parses the request, and passed it on to the handler. Otherwise, you will receive a `400 Bad Request` exception.

> NOTE: Messages will not be send if Jared does not show **🟢 Enabled** in the UI.

```
{
  "body": {
    "message": "Jared is an amazing app"
  },
  "recipient": {
    "handle": "handle@email.com",
  }
}
```

You can also send group messages by using the Group Chat's GUID. The GUID can by either:

1. Inspecting [webhook](webhooks.md) content.
2. Using the /barf command
3. Inspecting the chat database located at `~/Library/Messages/chat.db` using a SQLite database viewer.


```
{
  "body": {
    "message": "This is a group chat message."
  },
  "recipient": {
    "handle": "iMessage;+;chat100000000000",
  }
}
```

You may also specify attachments (such as images) to send. Simply specify file paths in the attachments array of the request body. Note that the file path specified must be accessible by the user that Jared is running under.

```
{
  ...
  "attachments": [
    {
      "filePath": "~/Pictures/funnyimage.jpeg"
    }
  ],
  "recipient": {
    "handle": "handle@email.com"
  }
}
```
