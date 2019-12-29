//
//  AboutViewController.swift
//  JaredUI
//
//  Created by Zeke Snider on 1/12/19.
//  Copyright © 2019 Zeke Snider. All rights reserved.
//

import Cocoa

class AboutViewController: NSViewController {
    @IBAction func updateButtonClicked(_ sender: Any) {
        NSWorkspace.shared.open(URL(string: "https://github.com/zekesnider/jared/releases")!)
    }
    @IBOutlet weak var versionField: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = ""
        
        let bundleVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        let bundleShortVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        versionField.stringValue = "Version \(bundleShortVersion ?? "??") (\(bundleVersion ?? "0"))"
    }
}
