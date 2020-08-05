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
    case invisibleInk = "invisible ink"
    case echo = "echo"
    case spotlight = "spotlight"
    case balloons = "balloons"
    case confetti = "confetti"
    case love = "love"
    case lasers = "lasers"
    case fireworks = "fireworks"
    case shootingStar = "shooting star"
    case celebration = "celebration"
    case unknown = "unknown"
    
    public init(fromIdentifier identifier: String?) {
        guard let identifier = identifier else {
            self = .regular
            return
        }
        switch(identifier) {
        case "com.apple.messages.effect.CKSpotlightEffect":
            self = .spotlight
        case "com.apple.messages.effect.CKSparklesEffect":
            self = .celebration
        case "com.apple.messages.effect.CKShootingStarEffect":
            self = .shootingStar
        case "com.apple.messages.effect.CKLasersEffect":
            self = .lasers
        case "com.apple.messages.effect.CKHeartEffect":
            self = .love
        case "com.apple.messages.effect.CKHappyBirthdayEffect":
            self = .balloons
        case "com.apple.messages.effect.CKFireworksEffect":
            self = .fireworks
        case "com.apple.messages.effect.CKConfettiEffect":
            self = .confetti
        case "com.apple.MobileSMS.expressivesend.loud":
            self = .loud
        case "com.apple.MobileSMS.expressivesend.invisibleink":
            self = .invisibleInk
        case "com.apple.MobileSMS.expressivesend.gentle":
            self = .gentle
        case "com.apple.messages.effect.CKEchoEffect":
            self = .echo
        case "com.apple.MobileSMS.expressivesend.impact":
            self = .slam
        default:
            self = .unknown
        }
    }
}
