//
//  main.swift
//  Jared 3.0 - Swiftified
//
//  Created by Zeke Snider on 4/3/16.
//  Copyright © 2016 Zeke Snider. All rights reserved.
//

import Foundation

public func SendText(_ message:String, toRoom: Room) {
    print("I want to send text \(message)")
    
    if let scriptPath = Bundle.main.url(forResource: "SendText", withExtension: "scpt")?.path {
        let task = Process()
        task.launchPath = "/usr/bin/osascript"
        task.arguments = [scriptPath, message, toRoom.GUID]
        task.launch()
    }
    
}

public func SendImage(_ imagePath:String, toRoom: Room) {
    print("I want to send image \(imagePath)")
    
    if let scriptPath = Bundle.main.url(forResource: "SendImage", withExtension: "scpt")?.path {
        let task = Process()
        task.launchPath = "/usr/bin/osascript"
        task.arguments = [scriptPath, imagePath, toRoom.GUID]
        task.launch()
    }
}

public func SendImage(_ imagePath:String, toRoom: Room, blockThread: Bool) {
    print("I want to send image \(imagePath)")
    
    if let scriptPath = Bundle.main.url(forResource: "SendImage", withExtension: "scpt")?.path {
        let task = Process()
        task.launchPath = "/usr/bin/osascript"
        task.arguments = [scriptPath, imagePath, toRoom.GUID]
        task.launch()
        if blockThread {
            task.waitUntilExit()
            Thread.sleep(forTimeInterval: Double(5))
        }
    }
}

public enum Compare {
    case startsWith
    case contains
    case `is`
    case containsURL
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
    
    public init(name: String, comparisons:[Compare: [String]], call: @escaping (String, Room) -> Void) {
        self.name = name
        self.comparisons = comparisons
        self.call = call
    }
    public init(name: String, comparisons:[Compare: [String]], call: @escaping (String, Room) -> Void, description: String) {
        self.name = name
        self.comparisons = comparisons
        self.call = call
        self.description = description
    }
    public init(name: String, comparisons:[Compare: [String]], call: @escaping (String, Room) -> Void, description: String, parameterSyntax: String) {
        self.name = name
        self.comparisons = comparisons
        self.call = call
        self.description = description
        self.parameterSyntax = parameterSyntax
    }
}

public func getAppSupportDirectory() -> URL{
    let appsupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
    return appsupport.appendingPathComponent("Jared")
}

public func matchesForRegexInText(_ regex: String!, text: String!) -> [String] {
    do {
        let regex = try NSRegularExpression(pattern: regex, options: [NSRegularExpression.Options.caseInsensitive])
        let nsString = text as NSString
        let results = regex.matches(in: text,
                                            options: [], range: NSMakeRange(0, nsString.length))
        return results.map { nsString.substring(with: $0.range)}
    } catch let error as NSError {
        print("invalid regex: \(error.localizedDescription)")
        return []
    }
}
