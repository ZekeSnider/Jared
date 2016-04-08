//
//  CoreModule.swift
//  Jared 3.0 - Swiftified
//
//  Created by Zeke Snider on 4/3/16.
//  Copyright © 2016 Zeke Snider. All rights reserved.
//

import Foundation
import Cocoa

struct CoreModule: RoutingModule {
    var routes: [Route]
    
    init() {
        let ping = Route(comparison: .StartsWith, string:"/ping", call: CoreModule.pingCall)
        let thankYou = Route(comparison: .StartsWith, string: "Thank you Jared", call: CoreModule.thanksJared)
        let version = Route(comparison: .StartsWith, string: "/version", call: CoreModule.getVersion)
        let send = Route(comparison: .StartsWith, string: "/send", call: CoreModule.sendRepeat)
        routes = [ping, thankYou, version, send]
    }
    
    static func pingCall(message:String, myRoom: Room) -> Void {
        let responseLocalized = NSLocalizedString("Pong!", comment: "Response for ping! command")
        SendText(responseLocalized, toRoom: myRoom)
    }
    
    static func thanksJared(message:String, myRoom: Room) -> Void {
        SendText("You're welcome.", toRoom: myRoom)
    }
    
    static func getVersion(message:String, myRoom: Room) -> Void {
        SendText("I am version 3.0 beta of Jared, compiled on Swift 2.2!", toRoom: myRoom)
    }
    
    static func sendRepeat(message:String, myRoom: Room) -> Void {
        let parameters = message.componentsSeparatedByString(",") as? [String]
        let repeatNum: Int = Int(parameters![1])!
        let delay = Int(parameters![2])
        print(parameters?.count)
        var textToSend: String
        
        if (parameters?.count > 4) {
            textToSend = (parameters![3..<((parameters?.count)!-1)] as? String)!
        }
        else {
            textToSend = parameters![3]
        }
        
        
        for _ in 1...repeatNum {
            SendText(textToSend, toRoom: myRoom)
            NSThread.sleepForTimeInterval(Double(delay!))
        }
    }
}