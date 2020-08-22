# Sample Module

This is a sample project to demonstrate how a third party plugin can be built. The main project requirements are:

* The project must be configured to build a bundle target
* `JaredFramework.framework` must be linked and included
* In `Info.plist` set `JaredFrameworkVersion` to the correct version
* In `Info.plist` set `Principal class` to be the the subclass of `RoutingModule` that should be used.

To create the routing module you must subclass `RoutingModule`. Routes can be defined and added to the `routes` member variable. Action handler methods must accept a `Message` variable and return void. Your initializer will receive a `MessageSender` object, and you can use it at any time to send messages. You can construct a `RecipientEntity` yourself, or you can just call `message.RespondTo()` to respond to the incoming message.

If you use `self` for callbacks, be very careful to use a weak reference, [to avoid memory leaks](https://zeke.dev/automatic-reference-counting-with-self/).