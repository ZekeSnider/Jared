<a name='Jared'/>
# Jared - A Chat Bot for iMessage

<a name='Download'/>
## Download Links  
### OS X  
Please check out the latest [release](https://github.com/ZekeSnider/Jared/releases/latest) page an up to date download.

## What is Jared?  
A powerful and easily extensibile iMessage bot. It makes it possible to add fancy chat bot features to any iMessage group chats (single person chats coming soon). It currently includes Twitter and Youtube link integrations, and some basic commands. API integrations, games, custom emotes, and much more can be added by installing plugins. 

<img src="/Screenshots/iTunes.gif" alt="iTunes demo" width="320"> <img src="/Screenshots/Youtube.gif" alt="Youtube demo" width="320"> <img src="/Screenshots/Tip.gif" alt="Tip demo" width="320"> <img src="/Screenshots/Jared.gif" alt="Jared demo" width="320">

Any pull requests and new GitHub issues are much appreciated! If you would like to develop a plugin for Jared, see the plugin section below. I'm always available on [Twitter](https://twitter.com/tngzeke) if you have any ideas/suggestions.

## How it works  
Jared implements an apple script scripting interface which is called upon by the Messages.app script handler. This allows all handling of requests to be taken care of in a native app written in Swift (not applescript). It's also multithreaded so it can take care of multiple requests at once. There's a few other iMessage bots I've seen but as far as I know this is the first one that is written in Swift and implements its own AppleScript interface. The plugin modularity via .bundles is another great feature. I think the interface for routing is quite nice, take a look at the source and check it out. Any improvements by pull requests would be much appreciated.

I've tried using private APIs such as MessagesKit to send/receive messages to no avail so far. If you have any leads on this front I'd love to hear about it.

## Installation  
Jared must be run a machine running OS X with an active messages account logged in. It has only been tested on 10.11 El Capitan. It may work in older OS X versions but I can't guarentee anything as there may have been changes to the Applescript scripting support. If you don't want Jared posting as you, it is recommended that you create a new Apple ID and user account on your mac, and run it in the background under that user. That way it's not using your main Apple ID.

Once you have Jared setup you can type /help to get a list of commands. /help,[command name] will give you specific information. Use /reload to reload plugins.

1. Download the Jared app and run it from the applications folder.  
See [download section](#Download) at the top. 

2. (Optional) Set API Keys
![API Entry](/Screenshots/Preferences.png)
Obtain [Twitter](https://apps.twitter.com) and [Youtube API](https://developers.google.com/youtube/registering_an_application) Keys and set them in the UI. This is only necessary if you want to make use of Twitter and Youtube integrations of course.

3. Download the Jared script handler and set it in Messages.app
![Messages Preferences](/Screenshots/MessagesPreferences.png)
Select AppleScript handler in Messages.app preferences, select "Open Script Folder", drag the Jared script handler into that folder, then select it as the handler.


## Plugins  
Plugins are loaded dynamically from the /Users/Your_User/Library/Application Support/Jared/Plugins folder. To install a module, drag it in there and then send "/reload" to Jared. 

### Plugin List  
* None yet!  
If you developed any plugins, please contact me a link so I can add a link here! I will be working on a few extra modules of my own as well, and will add them here when they are complete.

### Development  
If you would like to develop your own plugins, you need to build a .bundle to be loaded by Jared. You must include the [JaredFramework.framework](/JaredFramework/JaredFramework.framework) in your project and define a public subclass of RoutingModule. The bundle must set this class as the principle class in Info.plist. Info.plist must also contain a string for "JaredFrameworkVersion", the current version number is "J1.0.0".

Take a look at the [Sample project](/SampleModule) to see how the project should be configured. Also look at the modules in contained in the main project for examples of more complicated routings.  
