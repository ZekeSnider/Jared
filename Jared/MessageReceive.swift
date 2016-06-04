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
    override func performDefaultImplementation() -> AnyObject? {
        let parms = self.evaluatedArguments
        
        var message: String?
        var buddyName: String?
        var groupID: String?
        if let args = parms {
            message = args["MessageContent"] as? String
            buddyName = args["BuddyName"] as? String
            groupID = args["GroupID"] as? String
        }
        
        print(message)
        print(buddyName)
        print(groupID)
        
        if let appDelegate = NSApplication.sharedApplication().delegate as? AppDelegate {
            backgroundThread(0.0, background: {appDelegate.Router.routeMessage(message!, fromBuddy: buddyName!, forRoom: Room(GUID: groupID!, buddyName: buddyName!))})
        }
        
        return false
    }
    class func classString() -> String {
        return NSStringFromClass(self)
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