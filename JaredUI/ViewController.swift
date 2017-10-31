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
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "JaredIsDisabled" {
            updateTouchBarButton()
        }
    }
    deinit {
        UserDefaults.standard.removeObserver(self, forKeyPath: "JaredIsDisabled")
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.view.window!.title = "Preferences"
    }
    
    func updateTouchBarButton() {
        let defaults = UserDefaults.standard
        if (defaults.bool(forKey: "JaredIsDisabled")) {
            EnableDisableButton.title = "Enable"
        }
        else {
            EnableDisableButton.title = "Disable"
        }
    }
    
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


    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

