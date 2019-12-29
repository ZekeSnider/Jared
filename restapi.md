# REST API

If enabled, Jared exposes a webserver on the port `3000`. 


## Endpoints
`POST` `/message` 

This allows you to send (current) text messages to any Person. You will receive a 200 status code if Jared successfully parsed your request and passed it on to the handler. Otherwise, you may receive a 400 bad request exception. 

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