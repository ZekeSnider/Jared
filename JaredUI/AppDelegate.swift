//
//  AppDelegate.swift
//  JaredUI
//
//  Created by Zeke Snider on 4/5/16.
//  Copyright © 2016 Zeke Snider. All rights reserved.
//

import Cocoa
import Contacts

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var sender: Jared
    var router: PluginManager
    var server: JaredWebServer
    override init() {
        UserDefaults.standard.register(defaults: [
            JaredConstants.jaredIsDisabled: false,
            JaredConstants.restApiIsDisabled: true,
            JaredConstants.contactsAccess: CNAuthorizationStatus.notDetermined.rawValue,
            JaredConstants.fullDiskAccess: true
        ])
        PermissionsHelper.getContactsStatus()
        
        let configurationURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Jared")
            .appendingPathComponent("config.json")
        
        sender = Jared()
        router = PluginManager(sender: sender)
        server = JaredWebServer(sender: sender, configurationURL: configurationURL)
        super.init()
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if (ProcessInfo().arguments[safe: 1] == "-UITesting") {
            setStateForUITesting()
        }
        
        let messageDatabaseURL = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Messages").appendingPathComponent("chat.db")
        let viewController = NSApplication.shared.keyWindow?.contentViewController as? ViewController
		let dbHandler = DatabaseHandler(router: router.router, databaseLocation: messageDatabaseURL, diskAccessDelegate: viewController)
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    private func setStateForUITesting() {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
    }
}

