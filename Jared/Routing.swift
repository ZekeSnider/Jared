//
//  TwitterModule.swift
//  Jared
//
//  Created by Zeke Snider on 4/9/16.
//  Copyright © 2016 Zeke Snider. All rights reserved.
//

import Foundation
import JaredFramework

struct MessageRouting {
    var FrameworkVersion:String = "J1.0.0"
    var modules:[RoutingModule] = []
    var bundles:[Bundle] = []
    var supportDir: URL?
    
    init () {
        let filemanager = FileManager.default
        let appsupport = filemanager.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let supportDir = appsupport.appendingPathComponent("Jared")
        let pluginDir = supportDir.appendingPathComponent("Plugins")
        
        try! filemanager.createDirectory(at: supportDir, withIntermediateDirectories: true, attributes: nil)
        try! filemanager.createDirectory(at: pluginDir, withIntermediateDirectories: true, attributes: nil)
        
        print(supportDir.absoluteString)
        
        loadPlugins(pluginDir)
        addInternalModules()
    }
    
    mutating func addInternalModules() {
        let internalModules: [RoutingModule] = [CoreModule(), RESTModule(), TwitterModule()]
        
        modules.append(contentsOf: internalModules)
    }
    
    
    mutating func loadPlugins(_ pluginDir: URL) {
        //Loop through all files in our plugin directory
        let filemanager = FileManager.default
        let files = filemanager.enumerator(at: pluginDir, includingPropertiesForKeys: [], options: [.skipsHiddenFiles, .skipsPackageDescendants], errorHandler: nil)
        while let file = files?.nextObject() {
            guard let currentURL = file as? URL
                else {
                    continue
                }
            
            //Only unpackage bundles
            guard currentURL.pathExtension == "bundle"
                else {
                    continue
                }
            
            guard let myBundle = Bundle(url: currentURL)
                else {
                    continue
                }
            
            //Load it
            loadBundle(myBundle)
        }
    }
    
    mutating func loadBundle(_ myBundle: Bundle) {
        //Check version of the framework that this plugin is using
        guard myBundle.infoDictionary?["JaredFrameworkVersion"] as? String == self.FrameworkVersion
            else {
                return
            }
        
        //Cast the class to RoutingModule protocol
        guard let principleClass = myBundle.principalClass as? RoutingModule.Type
            else {
                return
            }
        
        //Initialize it
        guard let module: RoutingModule = principleClass.init()
            else {
                return
            }
        bundles.append(myBundle)
        
        //Add it to our modules
        modules.append(module)
    }
    
    mutating func reloadPlugins() {
        let appsupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let supportDir = appsupport.appendingPathComponent("Jared")
        let pluginDir = supportDir.appendingPathComponent("Plugins")
        
        modules = []
        for bundle in bundles {
            bundle.unload()
        }
        loadPlugins(pluginDir)
        addInternalModules()
    }
    
    func sendSingleDocumentation(_ routeName: String, forRoom: Room) {
        for aModule in modules {
            for aRoute in aModule.routes {
                if aRoute.name.lowercased() == routeName.lowercased() {
                    var documentation = "Command: "
                    documentation += routeName
                    documentation += "\n===========\n"
                    if aRoute.description != nil {
                        documentation += aRoute.description!
                    }
                    else {
                        documentation += "Description not provided."
                    }
                    documentation += "\n\n"
                    if let parameterString = aRoute.parameterSyntax {
                        documentation += "Parameters: "
                        documentation += parameterString
                    }
                    else {
                        documentation += "The developer of this route did not provide parameter documentation."
                    }
                    SendText(documentation, toRoom: forRoom)
                }
            }
        }
    }
    
    func sendDocumentation(_ myMessage: String, forRoom: Room) {
        let parsedMessage = myMessage.components(separatedBy: ",")
        
        if parsedMessage.count > 1 {
            sendSingleDocumentation(parsedMessage[1], forRoom: forRoom)
            return
        }
        
        var documentation: String = ""
        for aModule in modules {
            documentation += String(describing: type(of: aModule))
            documentation += ": "
            documentation += aModule.description
            documentation += "\n==============\n"
            
            for aRoute in aModule.routes {
                documentation += aRoute.name
                documentation += ": "
                
                if let aRouteDescription = aRoute.description {
                    documentation += aRouteDescription
                    documentation += "\n"
                }
            }
            documentation += "\n"
        }
        SendText(documentation, toRoom: forRoom)
    }
    
    mutating func routeMessage(_ myMessage: String, fromBuddy: String, forRoom: Room) {
        
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let matches = detector.matches(in: myMessage, options: [], range: NSMakeRange(0, myMessage.characters.count))
        let myLowercaseMessage = myMessage.lowercased()
        
        
        if myLowercaseMessage.contains("/help") {
            sendDocumentation(myMessage, forRoom: forRoom)
        }
        else if myLowercaseMessage == "/reload" {
            reloadPlugins()
            SendText("Successfully reloaded plugins.", toRoom: forRoom)
        }
        else {
            RootLoop: for aModule in modules {
                for aRoute in aModule.routes {
                    for aComparison in aRoute.comparisons {
                        
                        if aComparison.0 == .containsURL {
                            for match in matches {
                                let url = (myMessage as NSString).substring(with: match.range)
                                for comparisonString in aComparison.1 {
                                    if url.contains(comparisonString) {
                                        aRoute.call(url, forRoom)
                                    }
                                }
                            }
                        }
                            
                            
                        else if aComparison.0 == .startsWith {
                            for comparisonString in aComparison.1 {
                                if myLowercaseMessage.hasPrefix(comparisonString.lowercased()) {
                                    aRoute.call(myMessage, forRoom)
                                    break RootLoop
                                }
                            }
                        }
                            
                        else if aComparison.0 == .contains {
                            for comparisonString in aComparison.1 {
                                if myLowercaseMessage.contains(comparisonString.lowercased()) {
                                    aRoute.call(myMessage, forRoom)
                                    break RootLoop
                                }
                            }
                        }
                            
                        else if aComparison.0 == .is {
                            for comparisonString in aComparison.1 {
                                if myLowercaseMessage == comparisonString.lowercased() {
                                    aRoute.call(myMessage, forRoom)
                                    break RootLoop
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}


