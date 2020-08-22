[![Build Status](https://travis-ci.org/ZekeSnider/Jared.svg?branch=master)](https://travis-ci.org/ZekeSnider/Jared)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Swift 5.0](https://img.shields.io/badge/Swift-5.0-orange.svg?style=flat)](https://developer.apple.com/swift/)

<a name='Jared'/>

![Jared - An iMessage chat bot](/Documentation/Screenshots/JaredBanner.png)

<a name='Download'/>

## Download Links  
Please check out the [release](https://github.com/ZekeSnider/Jared/releases/latest) page for an up to date pre-compiled download.

## What is Jared?  
A powerful and easily extensible iMessage bot. It makes it possible to add chat bot features to any iMessage conversation. It includes some basic commands built in. API integrations, games, custom emotes, and much more can be added by using webhooks, the REST API, or by installing plugins. 

![Jared usage screenshot](/Documentation/Screenshots/Example.png)

Any pull requests and new GitHub issues are much appreciated! If you would like to develop a plugin for Jared, see the plugin section below. I'm always available on [Twitter](https://twitter.com/zekesnider) if you have any ideas/suggestions.

## Installation  
![Jared Main Window](/Documentation/Screenshots/MainWindow.png)

Jared must be run a machine running macOS with an active messages account logged in. It has only been tested on 10.14 Mojave and later. It may work on old versions of macOS but this is not guaranteed as there may have been changes to the message database's schema. If you don't want Jared posting as you, it is recommended that you create a new Apple ID and user account on your mac, and run it in the background under that user. That way it's not using your main Apple ID.

1. Download Jared.app and move it to the applications folder.  

See [download section](#Download) at the top. 

2. Run Jared.app, Allow Jared "Full Disk Access" in System Preferences.

This is required because of macOS permissions that limit access to the messages database. 

3. Grant access to automate Messages

If you are running macOS Catalina or later, you will need to allow Jared access to automate the message app. This allows Jared to send messages.

4. (Optional) Allow contacts access

You can optionally allow Jared access to your contacts so that it can provide and update names of contacts. The contacts are used to set/retrieve names only. 

5. (Optional) Start REST API server

If you wish to use the REST API, you will need to enable it. If you have a firewall enabled on your mac, you will see a dialog prompting you to allow Jared access to the port it is binding. 


## Built in commands
For reference, here is a list of the commands built in to Jared. Because functionality can be added with plugins, the built in functionality is kept light.

+ `/help`: Lists all commands. `/help,[command name]` will give you information on a specific route.
+ `/reload`: Reload plugins
+ `/enable`: Enables Jared
+ `/disable`: Disables Jared
+ `/ping`: Check if the chat bot is available
+ `/version`: Get the version of Jared running
+ `/send`: Send a message repeatedly
+ `/schedule`: Schedule messages
+ `/name`: Change what Jared calls you
+ `/whoami`: Get your name
+ `/barf`: Returns a json representation of your message, used for debugging
+ `Thank you Jared`: Thanks Jared


## Configuration  
A configuration file is located at `~/Library/Application Support/Jared/config.json` which allows you to:
+ Configure webhooks
+ Set REST API port
+ Disable specific routes

See [config-sample.json](Documentation/config-sample.json) for an example.

## Extensions
Jared Provides a variety of APIs to allow you to easily add your own commands, automate messages, and more. For all API documentation, see the [documentation hub](/Documentation).

### Plugins  
Additional routes can be added via modularized plugins, written in native Swift code. Plugins are loaded dynamically from the `~/Library/Application Support/Jared/Plugins` folder. To install a module, drag it in there and then send `/reload` to Jared, or click `Reload Plugins` in the UI.
  
For more information on developing your own plugins, see the [plugin documentation](Documentation/plugins.md). If you developed any plugins, please contact me a link so I can add a link here! I will be working on a few extra modules of my own as well, and will add them here when they are complete.

### Webhooks
Jared supports webhooks for sending your server information about incoming and outgoing messages. Your server can respond to these requests to send messages, or use the REST API to send messages at any time. To configure webhooks, add them to the `config.json` mentioned above. For more info on the webhooks API, check out the [webhook documentation](Documentation/webhooks.md).

### REST API
Jared contains a web server with a REST API that can be enabled. This allows you make HTTP requests to send messages to any recipient. For more information, [check out the REST API documentation](Documentation/restapi.md).

## How Jared works  
Jared reads from the Messages database on a set interval and queries for new messages. It provides a routing framework for actioning on messages, and uses AppleScript to send outgoing messages. It's also multi-threaded so it can take care of multiple requests at once. Jared allows expansion via `.bundle` plugin files, webhooks, and a REST API. This allows commands to be added without modifying the main Jared code base. 

I've tried using private APIs such as MessagesKit to send/receive messages to no avail so far. If you have any leads on this front I'd love to hear about it. 
