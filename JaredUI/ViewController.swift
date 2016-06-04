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
    
    var defaults: NSUserDefaults!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        defaults = NSUserDefaults.standardUserDefaults()
        
        YoutubeSecret.stringValue = defaults.stringForKey("YoutubeSecret") ?? "None"
        TwitterKey.stringValue = defaults.stringForKey("TwitterKey") ?? "None"
        TwitterSecret.stringValue = defaults.stringForKey("TwitterSecret") ?? "None"
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.view.window!.title = "Preferences"
    }
    
    @IBAction func setButtonPressed(sender: AnyObject) {
        defaults.setValue(YoutubeSecret.stringValue, forKey: "YoutubeSecret")
        defaults.setValue(TwitterKey.stringValue, forKey: "TwitterKey")
        defaults.setValue(TwitterSecret.stringValue, forKey: "TwitterSecret")
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

