# Routes

By using either native plugins, or a webhook configuration, you can define routes which are used to define triggers for messages. 

## Parameters

`name`: A string for the name of the route. This must be globally unique.
`comparisons`: A dictionary of `[Comapare: [String]]` that defines triggers for your route. The following is a list of `Compare` types:

+ `startsWith`: String starts with
+ `contains`: String contains
+ `is`: String matches exactly
+ `containsURL`: String contains this URL
+ `isReaction`: Message is a reaction message (tapback)


`parameterSyntax`: A string that describes how to exercise your route. 
`description`: A string that describes the purpose of this route
`call`: A callback method to execute when the route is triggered. This is only required for native plugins. If you're using webhooks, your webhook endpoint will be called automatically. 

## Example
The following is an example configuration of one of Jared's built in routes, `/send`.

```
{
	"name": "/send",
	"comparisons": {
		"startsWith": ["/send"]
	}
	"parameterSyntax": "/send,[number of times],[send delay],[message to send]",
	"description": "Send a message repeatedly"

}
```

