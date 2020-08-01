//
//  MockPluginManager.swift
//  JaredTests
//
//  Created by Zeke Snider on 8/1/20.
//  Copyright © 2020 Zeke Snider. All rights reserved.
//

import Foundation
import JaredFramework

let startWithString = "/startWith"
let containsString = "/contains"
let goodUrl = "https://zeke.dev"

class MockPluginManager: PluginManagerDelegate {
    var callCounts = [String: Int]()
    var disabled = [String: Bool]()
    
    func getAllRoutes() -> [Route] {
        let startWith = Route(name: startWithString, comparisons: [.startsWith: [startWithString]], call: {(message: Message) -> Void in self.increment(routeName: startWithString)}, description: "", parameterSyntax: "example syntax")
        let contains = Route(name: containsString, comparisons: [.contains: [containsString]], call: {(message) -> Void in self.increment(routeName: containsString)}, description: "")
        let url = Route(name: containsString, comparisons: [.containsURL: [goodUrl]], call: {(message) -> Void in self.increment(routeName: containsString)})
        
        return [startWith, contains, url]
    }
    
    func getAllModules() -> [RoutingModule] {
        return []
    }
    
    func reload() {
    }
    
    func enabled(routeName: String) -> Bool {
        return disabled[routeName, default: true]
    }
    
    func toggleDisable(routeName: String) -> Void {
        disabled[routeName] = !disabled[routeName, default: true]
    }
    
    func increment(routeName: String) -> Void {
        callCounts[routeName, default: 0] += 1
    }
}
