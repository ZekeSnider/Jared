# Plugins

Plugins allow you to add additional routing modules to Jared by using native Swift code.

If you would like to develop your own Jared plugins, you need to build a .bundle to be loaded by Jared. You must include JaredFramework.framework in your project and define a public subclass of RoutingModule. The bundle must set this class as the principle class in `Info.plist`. `Info.plist` must also contain a string for `JaredFrameworkVersion`, the current version number is `J3.0.0`.

To include JaredFramework you have 3 options:
1. Manually include it in the project (Grab it from the [release](https://github.com/ZekeSnider/Jared/releases/latest) page)
2. Use [Carthage](https://github.com/Carthage/Carthage)
3. Use [CocoaPods](https://cocoapods.org) (coming soon)

Take a look at the [Sample project](/Documentation/SampleModule) to see how the project should be configured. The README there contains instructions for how to build a plugin. Also look at the modules in contained in the main project for examples of more complicated routings. 