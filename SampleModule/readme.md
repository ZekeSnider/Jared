# Sample Module

This is a sample project to demonstrate how a third party plugin can be built. The main project requirements are:

* The project must be configured to build a bundle target
* `JaredFramework.framework` must be linked and included
* In `Info.plist` set `JaredFrameworkVersion` to the correct version
* In `Info.plist` set `Principal class` to be the the subclass of `RoutingModule` that should be used.

To create the routing module you must subclass `RoutingModule`. Routes can be defined and added to the `routes` member variable. Action handler methods must accept a `Message` variable and return void. They can call `Jared.Send` to send a message. You can construct a `RecipientEntity` yourself, or you can just call `message.RespondTo()` to respond to the incoming message.
