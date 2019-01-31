//
//  ViewController.swift
//  JaredUI
//
//  Created by Zeke Snider on 4/5/16.
//  Copyright © 2016 Zeke Snider. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    var defaults: UserDefaults!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let defaults = UserDefaults.standard
        
        defaults.addObserver(self, forKeyPath: "JaredIsDisabled", options: .new, context: nil)
        updateTouchBarButton()
    }
    
    deinit {
        if #available(OSX 10.12.2, *) {
            self.view.window?.unbind(NSBindingName(rawValue: #keyPath(touchBar)))
        }
        UserDefaults.standard.removeObserver(self, forKeyPath: "JaredIsDisabled")
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        let dbHandler = DatabaseHandler()
        if (!dbHandler.authorizationError) {
            dbHandler.start()
        }

        if #available(OSX 10.12.2, *) {
            self.view.window?.unbind(NSBindingName(rawValue: #keyPath(touchBar))) // unbind first
            self.view.window?.bind(NSBindingName(rawValue: #keyPath(touchBar)), to: self, withKeyPath: #keyPath(touchBar), options: nil)
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "JaredIsDisabled" {
            updateTouchBarButton()
        }
    }
    
    func updateTouchBarButton() {
        let defaults = UserDefaults.standard
        if (defaults.bool(forKey: "JaredIsDisabled")) {
            EnableDisableButton.title = "Enable"
            EnableDisableUIButton.title = "Enable"
            JaredStatusLabel.stringValue = "Jared is currently disabled"
            statusImage.image = NSImage(named: NSImage.statusUnavailableName)
        }
        else {
            EnableDisableButton.title = "Disable"
            EnableDisableUIButton.title = "Disable"
            JaredStatusLabel.stringValue = "Jared is currently enabled"
            statusImage.image = NSImage(named: NSImage.statusAvailableName)
        }
    }
    
    func displayAccessError() {
        let alert: NSAlert = NSAlert()
        alert.messageText = "Permission Error"
        alert.informativeText = "Jared requires \"full disk access\" to access the Messages database. This is an OS level restriction and can be enabled in System Preferences."
        alert.alertStyle = NSAlert.Style.warning
        alert.addButton(withTitle: "Open System Preferences")
        alert.addButton(withTitle: "Cancel")
        alert.icon = NSImage(named: NSImage.cautionName)
        
        let res = alert.runModal()
        
        if(res == NSApplication.ModalResponse.alertFirstButtonReturn) {
            NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles")!)
        }
        
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: "JaredIsDisabled")
        updateTouchBarButton()
        
        EnableDisableUIButton.isEnabled = false
        EnableDisableButton.isEnabled = false
    }
    
    @IBOutlet weak var JaredStatusLabel: NSTextField!
    @IBOutlet weak var EnableDisableUIButton: NSButton!
    @IBOutlet weak var EnableDisableButton: NSButtonCell!
    @IBOutlet weak var statusImage: NSImageView!
    
    @IBAction func EnableDisableAction(_ sender: Any) {
        let defaults = UserDefaults.standard
        
        if (defaults.bool(forKey: "JaredIsDisabled")) {
            defaults.set(false, forKey: "JaredIsDisabled")
        }
        else {
            defaults.set(true, forKey: "JaredIsDisabled")
        }
        
        updateTouchBarButton()
    }
    
    @IBAction func OpenPluginsButtonAction(_ sender: Any) {
        let filemanager = FileManager.default
        let appsupport = filemanager.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let supportDir = appsupport.appendingPathComponent("Jared")
        let pluginDir = supportDir.appendingPathComponent("Plugins")
        NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: pluginDir.path)
    }
    @IBAction func ReloadButtonPressed(_ sender: Any) {
        if let appDelegate = NSApplication.shared.delegate as? AppDelegate {
            appDelegate.Router.reloadPlugins()
        }
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}
