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
    
    if let scriptPath = NSBundle.mainBundle().URLForResource("SendText", withExtension: "scpt")?.path {
        let task = NSTask()
        task.launchPath = "/usr/bin/osascript"
        task.arguments = [scriptPath, message, toRoom.GUID]
        task.launch()
    }
    
}

func SendImage(imagePath:String, toRoom: Room) {
    print("I want to send image \(imagePath)")
    
    if let scriptPath = NSBundle.mainBundle().URLForResource("SendImage", withExtension: "scpt")?.path {
        let task = NSTask()
        task.launchPath = "/usr/bin/osascript"
        task.arguments = [scriptPath, imagePath, toRoom.GUID]
        task.launch()
    }
    
}

func SendImageAndDelete(imagePath:String, toRoom: Room) {
    print("I want to send image \(imagePath)")
    
    let task = NSTask()
    task.launchPath = "/usr/bin/osascript"
    task.arguments = ["/Users/Jared/Desktop/new/Jared/Jared/SendImageAndDelete.scpt", imagePath, toRoom.GUID]
    task.launch()
}

enum Compare {
    case StartsWith
    case Contains
    case Is
    case ContainsURL
}

protocol RoutingModule {
    var routes: [Route] {get}
}

struct Room {
    var GUID: String
    var buddyName: String?
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

extension CollectionType {
    /// Returns the element at the specified index iff it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Generator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}


func matchesForRegexInText(regex: String!, text: String!) -> [String] {
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


func getAppSupportDirectory() -> NSURL {
    let appsupport = NSFileManager.defaultManager().URLsForDirectory(.ApplicationSupportDirectory, inDomains: .UserDomainMask)[0]
    return appsupport.URLByAppendingPathComponent("Jared")
}

struct MessageRouting {
    var modules:[RoutingModule]
    var supportDir: NSURL?
    init () {
        let filemanager = NSFileManager.defaultManager()
        let appsupport = NSFileManager.defaultManager().URLsForDirectory(.ApplicationSupportDirectory, inDomains: .UserDomainMask)[0]
        let supportDir = appsupport.URLByAppendingPathComponent("Jared")
        
        try! filemanager.createDirectoryAtURL(supportDir, withIntermediateDirectories: true, attributes: nil)
        
        print(supportDir.absoluteString)
        
        modules = [CoreModule(), RESTModule(), TwitterModule(), EpicModule()]
    }
    
    func routeMessage(myMessage: String, fromBuddy: String, forRoom: Room) {
        
        let detector = try! NSDataDetector(types: NSTextCheckingType.Link.rawValue)
        let matches = detector.matchesInString(myMessage, options: [], range: NSMakeRange(0, myMessage.characters.count))
        
        
        
        RootLoop: for aModule in modules {
            for aRoute in aModule.routes {
                for aComparison in aRoute.comparisons {
                    
                    if aComparison.0 == .ContainsURL {
                        for match in matches {
                            let url = (myMessage as NSString).substringWithRange(match.range)
                            if url.containsString(aComparison.1) {
                                aRoute.call(url, forRoom)
                            }
                        }
                    }
                    
                    
                    else if aComparison.0 == .StartsWith {
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
