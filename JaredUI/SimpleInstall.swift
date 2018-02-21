//
//  SimpleInstall.swift
//  JaredUI
//
//  Created by Zeke Snider on 11/24/17.
//  Copyright © 2017 Zeke Snider. All rights reserved.
//

import Foundation

@discardableResult
func shell(_ args: String...) -> Int32 {
    let task = Process()
    task.launchPath = "/usr/bin/env"
    task.arguments = args
    task.launch()
    task.waitUntilExit()
    return task.terminationStatus
}

struct SimpleInstall {
    func Install() {
        copyFile()
        shell("killall", "Messages")
        shell ("defaults", "write", "~/Library/Containers/com.apple.soagent/Data/Library/Preferences/com.apple.messageshelper.AlertsController.plist", "AppleScriptNameKey", "-string", "\"Jared.applescript\"")
        shell("open", "/Applications/Messages.app")
        /*
        let myPath = NSString(string: "~/Library/Containers/com.apple.soagent/Data/Library/Preferences/com.apple.messageshelper.AlertsController.plist").expandingTildeInPath
        if let dict = NSMutableDictionary(contentsOfFile: myPath) {
            dict["AppleScriptNameKey"] = "Jared.applescript"
            dict.write(toFile: myPath, atomically: true )
        }*/
        
    }
    
    func copyFile() {
        let appSupportFilePath = URL(fileURLWithPath: NSString(string: "~/Library/Application Scripts/com.apple.iChat/").expandingTildeInPath).appendingPathComponent("Jared.applescript").path
        
        let bundlePath = Bundle.main.path(forResource: "Jared", ofType: ".applescript")
        
        let fileManager = FileManager.default
        
        do {
            try fileManager.copyItem(atPath: bundlePath!, toPath: appSupportFilePath)
        } catch {
            print("\n")
            print(error)
        }
    }
}
