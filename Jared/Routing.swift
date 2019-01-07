//
//  TwitterModule.swift
//  Jared
//
//  Created by Zeke Snider on 4/9/16.
//  Copyright © 2016 Zeke Snider. All rights reserved.
//

import Foundation
import JaredFramework
import AddressBook

struct MessageRouting {
    var FrameworkVersion:String = "J1.0.0"
    var modules:[RoutingModule] = []
    var bundles:[Bundle] = []
    var supportDir: URL?
    var disabled = false
    var config: [String: [String:AnyObject]]?
    
    init () {
        let filemanager = FileManager.default
        let appsupport = filemanager.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let supportDir = appsupport.appendingPathComponent("Jared")
        let pluginDir = supportDir.appendingPathComponent("Plugins")
        
        try! filemanager.createDirectory(at: supportDir, withIntermediateDirectories: true, attributes: nil)
        try! filemanager.createDirectory(at: pluginDir, withIntermediateDirectories: true, attributes: nil)
        
        let configPath = supportDir.appendingPathComponent("config.json")
        do {
            //Copy an empty config file if the conig file does not exist
            if !filemanager.fileExists(atPath: configPath.path) {
                try! filemanager.copyItem(at: (Bundle.main.resourceURL?.appendingPathComponent("config.json"))!, to: configPath)
            }
            
            //Read the JSON conig file
            let jsonData = try! NSData(contentsOfFile: supportDir.appendingPathComponent("config.json").path, options: .mappedIfSafe)
            if let jsonResult = try! JSONSerialization.jsonObject(with: jsonData as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String:AnyObject]
            {
                config = jsonResult["routes"] as? [String : [String: AnyObject]]
            }
        }
        
        loadPlugins(pluginDir)
        addInternalModules()
    }
    
    mutating func addInternalModules() {
        let internalModules: [RoutingModule] = [CoreModule()]
        
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
        if let principleClass = myBundle.principalClass as? RoutingModule.Type
        {
            //Initialize it
            let module: RoutingModule = principleClass.init()
            bundles.append(myBundle)
            
            //Add it to our modules
            modules.append(module)
            
        }
        else {
            return
        }
    }
    
    mutating func reloadPlugins() {
        let appsupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let supportDir = appsupport.appendingPathComponent("Jared")
        let pluginDir = supportDir.appendingPathComponent("Plugins")
        
        modules = []
        
        for bundle in bundles {
            bundle.unload()
        }
        
        bundles = []
        
        loadPlugins(pluginDir)
        addInternalModules()
    }
    
    func isRouteEnabled(routeName: String) -> Bool {
        if (config?[routeName.lowercased()]?["disabled"] as? Bool == true) {
            return false
        } else {
            return true
        }
    }
    
    func sendSingleDocumentation(_ routeName: String, forRoom: Room) {
        for aModule in modules {
            for aRoute in aModule.routes {
                if aRoute.name.lowercased() == routeName.lowercased() {
                    guard (isRouteEnabled(routeName: routeName)) else {
                        return
                    }
                    
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
        let matches = detector.matches(in: myMessage, options: [], range: NSMakeRange(0, myMessage.count))
        let myLowercaseMessage = myMessage.lowercased()
        
        let defaults = UserDefaults.standard
        
        guard !defaults.bool(forKey: "JaredIsDisabled") || myLowercaseMessage == "/enable" else {
            return
        }
        
        if myLowercaseMessage.contains("/help") {
            sendDocumentation(myMessage, forRoom: forRoom)
        }
        else if myLowercaseMessage == "/reload" {
            reloadPlugins()
            SendText("Successfully reloaded plugins.", toRoom: forRoom)
        }
        else if myLowercaseMessage == "/enable" {
            defaults.set(false, forKey: "JaredIsDisabled")
            SendText("Jared has been re-enabled. To disable, type /disable", toRoom: forRoom)
        }
        else if myLowercaseMessage == "/disable" {
            defaults.set(true, forKey: "JaredIsDisabled")
            SendText("Jared has been disabled. Type /enable to re-enable.", toRoom: forRoom)
        }
        else {
            RootLoop: for aModule in modules {
                for aRoute in aModule.routes {
                    guard (isRouteEnabled(routeName: aRoute.name)) else {
                        break
                    }
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


