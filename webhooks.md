# Webhooks

To add webhooks, add their URLs to `config.json`. Jared will hit the endpoint URL with a POST request when:

1. A message is sent
2. A message is received

The body of the POST request is in the following format:
```
{
  "body": {
    "message": "Jared is an amazing app"
  },
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
  "date": "2019-02-03T22:05:05.000Z"
}
```

```
{
  "body": {
    "message": "bloodline is the best song on thank u next"
  },
  "recipient": {
    "handle": "ariana@grande.com",
    "givenName": "Ariana",
    "isMe": false
  },
  "sender": {
    "handle": "zeke@swift.com",
    "givenName": "Taylor",
    "isMe": true
  },
  "date": "2019-02-03T22:05:05.000Z"
}
```