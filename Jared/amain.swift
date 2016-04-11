//
//  main.swift
//  Jared 3.0 - Swiftified
//
//  Created by Zeke Snider on 4/3/16.
//  Copyright © 2016 Zeke Snider. All rights reserved.
//

import Foundation

func SendText(message:String, toRoom: Room) {
    print("I want to send text \(message)")
    
    let task = NSTask()
    task.launchPath = "/usr/bin/osascript"
    task.arguments = ["/Users/Jared/Desktop/New Jared/Jared/Jared/SendText.scpt", message, toRoom.GUID]
    task.launch()
}

enum Compare {
    case StartsWith
    case Contains
    case Is
}

protocol RoutingModule {
    var routes: [Route] {get}
}

struct Room {
    var GUID: String
}

struct Route {
    var comparisons: [Compare: String]
    var parameterSyntax: String?
    var call: (String, Room) -> Void
    
    init(comparisons:[Compare: String], call: (String, Room) -> Void) {
        self.comparisons = comparisons
        self.call = call
    }
}

func backgroundThread(delay: Double = 0.0, background: (() -> Void)? = nil, completion: (() -> Void)? = nil) {
    dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0)) {
        if(background != nil){ background!(); }
        
        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
        dispatch_after(popTime, dispatch_get_main_queue()) {
            if(completion != nil){ completion!(); }
        }
    }
}

struct MessageRouting {
    var modules:[RoutingModule]
    init () {
        modules = [CoreModule(), RESTModule(), TwitterModule()]
    }
    
    func routeMessage(myMessage: String, fromBuddy: String, forRoom: Room) {
        RootLoop: for aModule in modules {
            for aRoute in aModule.routes {
                for aComparison in aRoute.comparisons {
                    
                    if aComparison.0 == .StartsWith {
                        if myMessage.hasPrefix(aComparison.1) {
                            aRoute.call(myMessage, forRoom)
                            break RootLoop
                        }
                    }
                        
                    else if aComparison.0 == .Contains {
                        if myMessage.containsString(aComparison.1) {
                            aRoute.call(myMessage, forRoom)
                            break RootLoop
                        }
                    }
                        
                    else if aComparison.0 == .Is {
                        if myMessage == aComparison.1 {
                            aRoute.call(myMessage, forRoom)
                            break RootLoop
                        }
                    }
                }
            }
        }
    }
}
