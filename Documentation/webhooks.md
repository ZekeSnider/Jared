# Webhooks

Jared provides a webhook API which allows you to be notified of messages being sent/received. You can reply inline to the webhook requests to respond, or make separate requests to the [REST API](restapi.md). You can use a site like https://webhook.site/ to debug and view webhook content.

## Configuration
To add webhooks, add their URLs to `config.json`'s `webhooks` key. You can define two types of webhooks:
1. Route webhook  
This is a webhook that is only called for messages that match specific routes defined. For more information, see the [routes documentation](routes.md).
2. Global webhook  
This is a webhook that is called for every single message sent or received.

```
  "webhooks": [
    {
      "url": "http://webhook.route.com",
      "routes": [
        {
          "name": "/hello",
          "description": "a test route",
          "parameterSyntax": "/hello",
          "comparisons": {
            "startsWith": ["/hello"]
          }
        }
      ]
    },
    {
      "url": "https://webhook.all.requests"
    }
  ],
```

In that example, the first webhook will only be called if a message starts with `/hello`. The second webhook will be called for every message.

## Webhook Requests

When a webhook is triggered, The body of the POST request is in the following format.

*outgoing message*
```
{
  "body": {
    "message": "Jared is an amazing app"
  },
  "sendStyle": "regular",
  "attachments": [],
  "recipient": {
    "handle": "+14256667777",
    "givenName": "Zeke",
    "isMe": true
  },
  "sender": {
    "handle": "taylor@swift.com",
    "givenName": "Taylor",
    "isMe": false
  },
  "date": "2019-02-03T22:05:05.000Z",
  "guid": "EA123B39-7A45-40D9-BF04-A748B3148695"
}
```

*incoming message*
```
{
  "body": {
    "message": "thank u next"
  },
  "sendStyle": "regular",
  "attachments": [],
  "recipient": {
    "handle": "ariana@grande.com",
    "givenName": "Ariana",
    "isMe": false
  },
  "sender": {
    "handle": "zeke@swift.com",
    "givenName": "Zeke",
    "isMe": true
  },
  "date": "2019-02-03T22:05:05.000Z",
  "guid": "EA123B39-7A45-40D9-BF04-A748B3148614"
}
```

*outgoing message with an attachment*
```
{
  "sender": {
    "handle": "me@me.com",
    "isMe": true
  },
  "sendStyle": "regular",
  "date": "2020-08-22T19:10:34.000Z",
  "attachments": [
    {
      "mimeType": "image/png",
      "id": 25491,
      "fileName": "1989 [Deluxe Edition].png",
      "isSticker": false,
      "filePath": "~/Library/Messages/Attachments/ae/14/F253C657-1B34-48E5-9010-28DA45C27904/1989 [Deluxe Edition].png"
    }
  ],
  "recipient": {
    "handle": "friend@icloud.com",
    "isMe": false
  },
  "body": {
    "message": "\ufffcHey check out this great image!"
  },
  "guid": "441F4CA4-22C3-44DC-9E2A-6A43C44D61F2"
}
```

*outgoing group message*
```
{
  "sender": {
    "handle": "+14256667777",
    "isMe": true
  },
  "sendStyle": "regular",
  "date": "2020-08-22T19:06:58.000Z",
  "attachments": [],
  "recipient": {
    "name": "Testing Room",
    "handle": "iMessage;+;chat123456789999111888",
    "participants": [
      {
        "handle": "handle@icloud.com",
        "isMe": false
      },
      {
        "handle": "handle2@gmail.com",
        "isMe": false
      }
    ]
  },
  "body": {
    "message": "Don't take the money"
  },
  "guid": "441F4CA4-22C3-44DC-9E2A-6A23C44D61F1"
}
```

*incoming group message*
```
{
  "sender": {
    "handle": "handle@icloud.com",
    "givenName": "Jared",
    "isMe": false
  },
  "sendStyle": "regular",
  "date": "2020-08-22T19:59:13.000Z",
  "attachments": [],
  "recipient": {
    "name": "Testing Room",
    "handle": "iMessage;+;chat123456789999111888",
    "participants": [
      {
        "handle": "friend@icloud.com",
        "givenName": "Betty",
        "isMe": false
      },
      {
        "handle": "handle2@gmail.com",
        "isMe": false
      }
    ]
  },
  "body": {
    "message": "We can talk it so good"
  },
  "guid": "760B85F7-122D-42A5-ACE0-44F44150BF04"
}
```

## Webhook Responses
When called, Jared will wait for 10 seconds for a response from the webhook endpoint. If a response is received in time, Jared will then respond to the triggering message with the content of the webhook response. The response must have a `200` HTTP status code, and be in the following format:
```
{
  "success": true,
  "body": { 
    "message": "We're on each other's team" 
  }
}
```

In the case that the server is unable to process the request, you may return back an error response instead. Jared will log this for debugging purposes.
```
{
  "success": false,
  "error": "Too many concurrent requests"
}
```

## Sending other messages
If you wish to send multiple messages, cannot fit inside the 10 second timeout, or have other non-synchronous use cases, your server can make a request to send a message at any time using Jared's [REST API](restapi.md).

