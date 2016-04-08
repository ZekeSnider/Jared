//
//  MessageReceivedNotification.swift
//  Jared
//
//  Created by Zeke Snider on 4/5/16.
//  Copyright © 2016 Zeke Snider. All rights reserved.
//

import Foundation
import Cocoa

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
            appDelegate.Router.routeMessage(message!, fromBuddy: buddyName!, forRoom: Room(GUID: groupID!))
        }
        
        
        return false
    }
    class func classString() -> String {
        return NSStringFromClass(self)
    }
}