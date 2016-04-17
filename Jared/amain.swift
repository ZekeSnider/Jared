//
//  main.swift
//  Jared 3.0 - Swiftified
//
//  Created by Zeke Snider on 4/3/16.
//  Copyright © 2016 Zeke Snider. All rights reserved.
//

import Foundation

public func SendText(message:String, toRoom: Room) {
    print("I want to send text \(message)")
    
    if let scriptPath = NSBundle.mainBundle().URLForResource("SendText", withExtension: "scpt")?.path {
        let task = NSTask()
        task.launchPath = "/usr/bin/osascript"
        task.arguments = [scriptPath, message, toRoom.GUID]
        task.launch()
    }
    
}

public func SendImage(imagePath:String, toRoom: Room) {
    print("I want to send image \(imagePath)")
    
    if let scriptPath = NSBundle.mainBundle().URLForResource("SendImage", withExtension: "scpt")?.path {
        let task = NSTask()
        task.launchPath = "/usr/bin/osascript"
        task.arguments = [scriptPath, imagePath, toRoom.GUID]
        task.launch()
    }
}

public func SendImage(imagePath:String, toRoom: Room, blockThread: Bool) {
    print("I want to send image \(imagePath)")
    
    if let scriptPath = NSBundle.mainBundle().URLForResource("SendImage", withExtension: "scpt")?.path {
        let task = NSTask()
        task.launchPath = "/usr/bin/osascript"
        task.arguments = [scriptPath, imagePath, toRoom.GUID]
        task.launch()
        if blockThread {
            task.waitUntilExit()
            NSThread.sleepForTimeInterval(Double(5))
        }
    }
}

public func SendImageAndDelete(imagePath:String, toRoom: Room) {
    print("I want to send image \(imagePath)")
    
    let task = NSTask()
    task.launchPath = "/usr/bin/osascript"
    task.arguments = ["/Users/Jared/Desktop/new/Jared/Jared/SendImageAndDelete.scpt", imagePath, toRoom.GUID]
    task.launch()
}

public enum Compare {
    case StartsWith
    case Contains
    case Is
    case ContainsURL
}

public protocol RoutingModule {
    var routes: [Route] {get}
    var description: String {get}
    init()
}

public struct Room {
    public var GUID: String
    public var buddyName: String?
    public init(GUID: String, buddyName: String) {
        self.GUID = GUID
        self.buddyName = buddyName
    }
    public init(GUID:String) {
        self.GUID = GUID
    }
}

public struct Route {
    public var name: String
    public var comparisons: [Compare: [String]]
    public var parameterSyntax: String?
    public var description: String?
    public var call: (String, Room) -> Void
    
    public init(name: String, comparisons:[Compare: [String]], call: (String, Room) -> Void) {
        self.name = name
        self.comparisons = comparisons
        self.call = call
    }
    public init(name: String, comparisons:[Compare: [String]], call: (String, Room) -> Void, description: String) {
        self.name = name
        self.comparisons = comparisons
        self.call = call
        self.description = description
    }
}

public func getAppSupportDirectory() -> NSURL{
    let appsupport = NSFileManager.defaultManager().URLsForDirectory(.ApplicationSupportDirectory, inDomains: .UserDomainMask)[0]
    return appsupport.URLByAppendingPathComponent("Jared")
}

public func matchesForRegexInText(regex: String!, text: String!) -> [String] {
    
    do {
        let regex = try NSRegularExpression(pattern: regex, options: [])
        let nsString = text as NSString
        let results = regex.matchesInString(text,
                                            options: [], range: NSMakeRange(0, nsString.length))
        return results.map { nsString.substringWithRange($0.range)}
    } catch let error as NSError {
        print("invalid regex: \(error.localizedDescription)")
        return []
    }
}
