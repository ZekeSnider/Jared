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
        SqliteTest.test()
        self.view.window!.title = "Preferences"
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
        }
        else {
            EnableDisableButton.title = "Disable"
            EnableDisableUIButton.title = "Disable"
            JaredStatusLabel.stringValue = "Jared is currently enabled"
        }
    }
    
    @IBOutlet weak var JaredStatusLabel: NSTextField!
    @IBOutlet weak var EnableDisableUIButton: NSButton!
    @IBOutlet weak var EnableDisableButton: NSButtonCell!
    
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

    @IBAction func Fastinstall(_ sender: Any) {
        let myInstall = SimpleInstall()
        myInstall.Install()
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

