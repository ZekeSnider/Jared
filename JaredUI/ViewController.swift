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

        
        defaults = UserDefaults.standard
        
        YoutubeSecret.stringValue = defaults.string(forKey: "YoutubeSecret") ?? "None"
        TwitterKey.stringValue = defaults.string(forKey: "TwitterKey") ?? "None"
        TwitterSecret.stringValue = defaults.string(forKey: "TwitterSecret") ?? "None"
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.view.window!.title = "Preferences"
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

