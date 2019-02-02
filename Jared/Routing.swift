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
    var routeConfig: [String: [String:AnyObject]]?
    var webhooks: [String]?
    var urlSession: URLSession?
    
    init () {
        let filemanager = FileManager.default
        let appsupport = filemanager.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let supportDir = appsupport.appendingPathComponent("Jared")
        let pluginDir = supportDir.appendingPathComponent("Plugins")
        urlSession = URLSession(configuration: URLSessionConfiguration.ephemeral)
        
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
                routeConfig = jsonResult["routes"] as? [String : [String: AnyObject]]
                webhooks = jsonResult["webhooks"] as? [String]
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
        if (routeConfig?[routeName.lowercased()]?["disabled"] as? Bool == true) {
            return false
        } else {
            return true
        }
    }
    
    func sendSingleDocumentation(_ routeName: String, to recipient: RecipientEntity) {
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
                    
                    Send(documentation, to: recipient)
                }
            }
        }
    }
    
    func sendDocumentation(_ myMessage: String, to recipient: RecipientEntity) {
        let parsedMessage = myMessage.components(separatedBy: ",")
        
        if parsedMessage.count > 1 {
            sendSingleDocumentation(parsedMessage[1], to: recipient)
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
        Send(documentation, to: recipient)
    }
    
    mutating private func notifyWebhooks(message: Message) {
        let webhookBody = MessageRouting.createWebhookBody(message)
        // loop over all webhooks, if the list is null, do nothing.
        for webhookBase in webhooks ?? [] {
            guard let url = URL(string: webhookBase) else {
                break
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = webhookBody
            request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            
            urlSession?.dataTask(with: request).resume()
        }
    }
    
    static private func createWebhookBody(_ message: Message) -> Data {
        return try! JSONEncoder().encode(message)
    }
    
    mutating func route(message myMessage: Message) {
        notifyWebhooks(message: myMessage)
        // Currently don't process any images
        guard let messageText = myMessage.body as? TextBody else {
            return
        }
        
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let matches = detector.matches(in: messageText.message, options: [], range: NSMakeRange(0, messageText.message.count))
        let myLowercaseMessage = messageText.message.lowercased()
        
        let defaults = UserDefaults.standard
        
        guard !defaults.bool(forKey: "JaredIsDisabled") || myLowercaseMessage == "/enable" else {
            return
        }
        
        if myLowercaseMessage.contains("/help") {
            sendDocumentation(messageText.message, to: myMessage.sender as! RecipientEntity)
        }
        else if myLowercaseMessage == "/reload" {
            reloadPlugins()
            Send("Successfully reloaded plugins.", to: myMessage.sender as! RecipientEntity)
        }
        else if myLowercaseMessage == "/enable" {
            defaults.set(false, forKey: "JaredIsDisabled")
            Send("Jared has been re-enabled. To disable, type /disable", to: myMessage.sender as! RecipientEntity)
        }
        else if myLowercaseMessage == "/disable" {
            defaults.set(true, forKey: "JaredIsDisabled")
            Send("Jared has been disabled. Type /enable to re-enable.", to: myMessage.sender as! RecipientEntity)
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
                                let url = (messageText.message as NSString).substring(with: match.range)
                                for comparisonString in aComparison.1 {
                                    if url.contains(comparisonString) {
                                        let urlMessage = Message(body: TextBody(url), date: myMessage.date ?? Date(), sender: myMessage.sender, recipient: myMessage.recipient)
                                        aRoute.call(urlMessage)
                                    }
                                }
                            }
                        }
                            
                        else if aComparison.0 == .startsWith {
                            for comparisonString in aComparison.1 {
                                if myLowercaseMessage.hasPrefix(comparisonString.lowercased()) {
                                    aRoute.call(myMessage)
                                    break RootLoop
                                }
                            }
                        }
                            
                        else if aComparison.0 == .contains {
                            for comparisonString in aComparison.1 {
                                if myLowercaseMessage.contains(comparisonString.lowercased()) {
                                    aRoute.call(myMessage)
                                    break RootLoop
                                }
                            }
                        }
                            
                        else if aComparison.0 == .is {
                            for comparisonString in aComparison.1 {
                                if myLowercaseMessage == comparisonString.lowercased() {
                                    aRoute.call(myMessage)
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
