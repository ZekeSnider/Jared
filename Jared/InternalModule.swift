//
//  CoreModule.swift
//  Jared 3.0 - Swiftified
//
//  Created by Zeke Snider on 4/3/16.
//  Copyright © 2016 Zeke Snider. All rights reserved.
//

import Foundation
import Cocoa
import JaredFramework

class InternalModule: RoutingModule {
    var description: String = NSLocalizedString("InternalModule")
    var routes: [Route] = []
    var defaults: UserDefaults
    var pluginManager: PluginManagerDelegate?
    
    required public convenience init() {
        self.init(pluginManager: nil)
    }
    
    init(pluginManager: PluginManagerDelegate?) {
        self.pluginManager = pluginManager
        defaults = UserDefaults.standard
        
        let enable = Route(name:"/enable", comparisons: [.startsWith: ["/enable"]], call: self.enable, description: localized("enableDescription"))
        let disable = Route(name:"/disable", comparisons: [.startsWith: ["/disable"]], call: self.disable, description: localized("disableDescription"))
        let documentation = Route(name:"/help", comparisons: [.startsWith: ["/help"]], call: self.sendDocumentation, description: localized("helpDescription"))
        let reload = Route(name:"/reload", comparisons: [.startsWith: ["/reload"]], call: self.reload, description: localized("reloadDescription"))
        
        routes = [enable, disable, documentation, reload]
    }
    
    func enable(message: Message) -> Void {
        defaults.set(false, forKey: "JaredIsDisabled")
        Jared.Send(localized("enabledMessage"), to: message.RespondTo())
    }
    
    func disable(message: Message) -> Void {
        defaults.set(true, forKey: "JaredIsDisabled")
        Jared.Send(localized("disabledMessage"), to: message.RespondTo())
    }
    
    func reload(message: Message) -> Void {
        pluginManager?.reload()
        Jared.Send(localized("reloadMessage"), to: message.RespondTo())
    }
    
    func sendDocumentation(message: Message) {
        let parameters = message.getTextParameters()
        if parameters?.count == 2 {
            Jared.Send(singleDocumentation(parameters![1]), to: message.RespondTo())
            return
        }
        
        var documentation: String = ""
        for aModule in pluginManager!.getAllModules() {
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
        Jared.Send(documentation, to: message.RespondTo())
    }
    
    private func singleDocumentation(_ routeName: String) -> String {
        for aModule in pluginManager!.getAllModules() {
            for aRoute in aModule.routes {
                if aRoute.name.lowercased() == routeName.lowercased() {
                    guard (pluginManager?.enabled(routeName: routeName) == true) else {
                        return ""
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
                    
                    return documentation
                }
            }
        }
        return ""
    }
    
    private func localized(_ key: String) -> String {
        return NSLocalizedString(key, tableName: "CoreStrings", comment: "")
    }
}
