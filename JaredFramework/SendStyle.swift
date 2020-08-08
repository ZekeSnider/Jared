//
//  SendStyle.swift
//  JaredFramework
//
//  Created by Zeke Snider on 8/2/20.
//  Copyright © 2020 Zeke Snider. All rights reserved.
//

import Foundation

public enum SendStyle: String {
    case regular = "regular"
    case slam = "slam"
    case loud = "loud"
    case gentle = "gentle"
    case invisibleInk = "invisibleInk"
    case echo = "echo"
    case spotlight = "spotlight"
    case balloons = "balloons"
    case confetti = "confetti"
    case love = "love"
    case lasers = "lasers"
    case fireworks = "fireworks"
    case shootingStar = "shootingStar"
    case celebration = "celebration"
    case unknown = "unknown"
    
    public init(fromIdentifier identifier: String?) {
        guard let identifier = identifier else {
            self = .regular
            return
        }
        
        if let configurationMapping = Configuration.shared.parameters?.sendStyle[identifier] {
            self.init(rawValue: configurationMapping)!
        } else {
            self = .unknown
        }
    }
}
