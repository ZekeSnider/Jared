#Jared  
An powerful and easily extensibile iMessage bot

##What is Jared?

##Installation
Jared must be run a machine running OS X with an active messages account logged in. It has only been tests on 10.11 El Capitan. It may work in older OS X versions but nothing is guarenteed as there may have been changes to the Applescript scripting support.

1. Download the Jared app and run it from the applications folder.  
You currently have to build it from source. A stable download will be available at a later date.  

2. (Optional) Set API Keys
![API Entry](/Screenshots/Preferences.png)
Obtain [Twitter](https://apps.twitter.com) and [Youtube API](https://developers.google.com/youtube/registering_an_application) Keys and set them in the UI. This is only necessary if you want to make use of Twitter and Youtube integrations of course.

3. Download the Jared script handler and set it in Messages.app
![Messages Preferences](/Screenshots/MessagesPreferences.png)
Select AppleScript handler in Messages.app preferences, select "Open Script Folder", drag the [Jared script](/Jared.scpt) into that folder, then select it as the handler.


##Plugins
Plugins are loaded dynamically from the /Users/Your_User/Library/Application Support/Jared/Plugins folder. To install a module, drag it in there and then send "/reload" to Jared. 

###Plugin List
* None yet!  
If you developed any plugins, please contact me a link so I can add a link here! 

If you would like to develop your own plugins, you need to build a .bundle to be loaded by Jared. 





