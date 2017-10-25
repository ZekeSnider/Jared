//
//  MessageReceivedNotification.swift
//  Jared
//
//  Created by Zeke Snider on 4/5/16.
//  Copyright © 2016 Zeke Snider. All rights reserved.
//

import Foundation
import Cocoa
import JaredFramework

class MessageReceive: NSScriptCommand {
    override func performDefaultImplementation() -> Any? {
        let parms = self.evaluatedArguments
        
        var message: String?
        var buddyName: String?
        var groupID: String?
        var buddyHandle: String?
        if let args = parms {
            message = args["MessageContent"] as? String
            buddyName = args["BuddyName"] as? String
            groupID = args["GroupID"] as? String
            buddyHandle = args["BuddyHandle"] as? String
        }
        
        print(message ?? "No Message Provided")
        print(buddyName ?? "No Buddy Name")
        print(groupID ?? "No Group ID.")
        
        if let appDelegate = NSApplication.shared.delegate as? AppDelegate {
            backgroundThread(0.0, background: {
                appDelegate.Router.routeMessage(message!, fromBuddy: buddyName!, forRoom: Room(GUID: groupID!, buddyName: buddyName!, buddyHandle: buddyHandle ?? ""))
            })
        }
        
        return false
    }
    class func classString() -> String {
        return NSStringFromClass(self)
    }
}

func backgroundThread(_ delay: Double = 0.0, background: (() -> Void)? = nil, completion: (() -> Void)? = nil) {
    DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
        if(background != nil){ background!(); }
        
        let popTime = DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: popTime) {
            if(completion != nil){ completion!(); }
        }
    }
}
