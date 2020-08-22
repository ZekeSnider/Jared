//
//  PluginManager.swift
//  Jared
//
//  Created by Zeke Snider on 4/9/16.
//  Copyright © 2016 Zeke Snider. All rights reserved.
//

import Foundation
import JaredFramework

class PluginManager: PluginManagerDelegate {
    var FrameworkVersion: String = "J3.0.0"
    private var modules: [RoutingModule] = []
    private var bundles: [Bundle] = []
    var pluginDir: URL
    var disabled = false
    var config: ConfigurationFile
    var webhooks: [String]?
    var webHookManager: WebHookManager
    var sender: MessageSender
    public var router: Router!
    
    init (sender: MessageSender, configuration: ConfigurationFile, pluginDir: URL) {
        self.sender = sender
        self.pluginDir = pluginDir
        self.config = configuration
        
        webHookManager = WebHookManager(webhooks: configuration.webhooks, sender: sender)
        router = Router(pluginManager: self, messageDelegates: [webHookManager])
        
        loadPlugins()
        addInternalModules()
    }
    
    private func addInternalModules() {
        modules.append(CoreModule(sender: sender))
        modules.append(InternalModule(sender: sender, pluginManager: self))
        modules.append(webHookManager)
    }
    
    func loadPlugins() {
        //Loop through all files in our plugin directory
        let filemanager = FileManager.default
        let files = filemanager.enumerator(at: pluginDir, includingPropertiesForKeys: [],
            options: [.skipsHiddenFiles, .skipsPackageDescendants], errorHandler: nil)
        
        while let file = files?.nextObject() as? URL {
            if let bundle = validateBundle(file) {
                loadBundle(bundle)
            }
        }
    }
    
    private func validateBundle(_ file: URL) -> Bundle? {
        //Only unpackage bundles
        guard file.pathExtension == "bundle" else {
            return nil
        }
        
        guard let myBundle = Bundle(url: file) else {
            return nil
        }
        
        return myBundle
    }
    
    func loadBundle(_ myBundle: Bundle) {
        //Check version of the framework that this plugin is using
        //TODO: Add better version comparison (2.1.0 should be compatible with 2.0.0)
        guard myBundle.infoDictionary?["JaredFrameworkVersion"] as? String == self.FrameworkVersion else {
            return
        }
        
        //Cast the class to RoutingModule protocol
        guard let principleClass = myBundle.principalClass as? RoutingModule.Type else {
            return
        }
        
        //Initialize it
        let module: RoutingModule = principleClass.init(sender: sender)
        bundles.append(myBundle)
        
        //Add it to our modules
        modules.append(module)
    }
    
    func reload() {        
        modules.removeAll()
        
        for bundle in bundles {
            bundle.unload()
        }
        
        bundles.removeAll()
        
        loadPlugins()
        addInternalModules()
    }
    
    func enabled(routeName: String) -> Bool {
        if let routeConfig = config.routes[routeName.lowercased()] {
            return !routeConfig.disabled
        } else {
            return true
        }
    }
    
    func getAllModules() -> [RoutingModule] {
        return modules
    }
    
    func getAllRoutes() -> [Route] {
        return modules.flatMap { module in module.routes }
    }
}
