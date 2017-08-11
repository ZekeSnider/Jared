//
//  ViewController.swift
//  JaredUI
//
//  Created by Zeke Snider on 4/5/16.
//  Copyright © 2016 Zeke Snider. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    @IBOutlet weak var YoutubeSecret: NSTextField!
    @IBOutlet weak var TwitterKey: NSTextField!
    @IBOutlet weak var TwitterSecret: NSTextField!
    
    var defaults: UserDefaults!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        let defaults = UserDefaults.standard
        if (defaults.bool(forKey: "JaredIsDisabled")) {
            EnableDisableButton.title = "Disable"
        }
        else {
            EnableDisableButton.title = "Enable"
        }
        
        
        YoutubeSecret.stringValue = defaults.string(forKey: "YoutubeSecret") ?? "None"
        TwitterKey.stringValue = defaults.string(forKey: "TwitterKey") ?? "None"
        TwitterSecret.stringValue = defaults.string(forKey: "TwitterSecret") ?? "None"
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.view.window!.title = "Preferences"
    }
    
    @IBOutlet weak var EnableDisableButton: NSButtonCell!
    
    @IBAction func EnableDisableAction(_ sender: Any) {
        let defaults = UserDefaults.standard
        
        if (defaults.bool(forKey: "JaredIsDisabled")) {
            defaults.set(false, forKey: "JaredIsDisabled")
            EnableDisableButton.title = "Enable"
        }
        else {
            defaults.set(true, forKey: "JaredIsDisabled")
            EnableDisableButton.title = "Disable"
        }
        
        print("hello world")
    }
    @IBAction func setButtonPressed(_ sender: AnyObject) {
        defaults.setValue(YoutubeSecret.stringValue, forKey: "YoutubeSecret")
        defaults.setValue(TwitterKey.stringValue, forKey: "TwitterKey")
        defaults.setValue(TwitterSecret.stringValue, forKey: "TwitterSecret")
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

