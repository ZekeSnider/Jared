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

public func NSLocalizedString(_ key: String) -> String {
    return NSLocalizedString(key, tableName: "CoreStrings", comment: "")
}


struct CoreModule: RoutingModule {
    var description: String = NSLocalizedString("CoreDescription")
    var routes: [Route] = []
    
    let mystring = NSLocalizedString("hello", tableName: "CoreStrings", value: "", comment: "")
    
    init() {
        let ping = Route(name:"/ping", comparisons: [.startsWith: ["/ping"]], call: self.pingCall, description: NSLocalizedString("pingDescription"))
        
        let thankYou = Route(name:"Thank You", comparisons: [.startsWith: [NSLocalizedString("ThanksJaredCommand")]], call: self.thanksJared, description: NSLocalizedString("ThanksJaredResponse"))
        
        let version = Route(name: "/version", comparisons: [.startsWith: ["/version"]], call: self.getVersion, description: "versionDescription")
        
        let send = Route(name: "/send", comparisons: [.startsWith: ["/send"]], call: self.sendRepeat, description: NSLocalizedString("sendDescription"),parameterSyntax: NSLocalizedString("sendSyntax"))

        routes = [ping, thankYou, version, send]
    }
    
    
    func pingCall(_ message:String, myRoom: Room) -> Void {
        SendText(NSLocalizedString("PongResponse"), toRoom: myRoom)
    }
    
    func thanksJared(_ message:String, myRoom: Room) -> Void {
        SendText(NSLocalizedString("WelcomeResponse"), toRoom: myRoom)
    }
    
    func getVersion(_ message:String, myRoom: Room) -> Void {
        SendText(NSLocalizedString("versionResponse"), toRoom: myRoom)
    }
    
    func sendRepeat(_ message:String, myRoom: Room) -> Void {
        let parameters = message.components(separatedBy: ",")
        if let repeatNum: Int = Int(parameters[1]), let delay = Int(parameters[2]) {
            print(parameters.count)
            var textToSend: String
            
            if (parameters.count > 4) {
                textToSend = "lol"
            }
            else {
                textToSend = parameters[3]
            }
            
            for _ in 1...repeatNum {
                SendText(textToSend, toRoom: myRoom)
                Thread.sleep(forTimeInterval: Double(delay))
            }
        }
        
    }
}
