//
//  TouchBarTextFieldExtension.swift
//  Jared
//
//  Created by Zeke Snider on 8/10/17.
//  Copyright © 2017 Zeke Snider. All rights reserved.
//

import Foundation
import Cocoa

extension NSTextView {
    @available(OSX 10.12.2, *)
    override open func makeTouchBar() -> NSTouchBar? {
        let touchBar = super.makeTouchBar()
        touchBar?.delegate = self
        
        return touchBar
    }
}
