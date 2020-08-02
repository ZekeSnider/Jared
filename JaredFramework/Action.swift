//
//  main.swift
//  Jared 3.0 - Swiftified
//
//  Created by Zeke Snider on 4/3/16.
//  Copyright © 2016 Zeke Snider. All rights reserved.
//

import Foundation

public enum ActionType: String {
    case like = "like"
    case love = "love"
    case laugh = "laugh"
    case exclaim = "exclaim"
    case question = "question"
    case unknown = "unknown"
    
    init(fromActionTypeInt actionTypeInt: Int) {
        switch(actionTypeInt) {
        case 2005:
            self = .question
        default:
            self = .unknown
        }
    }
}

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
    
    
    init(fromIdentifier identifier: String?) {
        guard let identifier = identifier else {
            self = .regular
            return
        }
        switch(identifier) {
        case "com.apple.messages.effect.CKShootingStarEffect":
            self = .shootingStar
        case "com.apple.messages.effect.CKLasersEffect":
            self = .lasers
        case "com.apple.messages.effect.CKHeartEffect":
            self = .love
        case "com.apple.messages.effect.CKHappyBirthdayEffect":
            self = .confetti
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

public struct Action: Encodable {
	public var type: ActionType
	public var targetGUID: String
	
	enum CodingKeys : String, CodingKey{
        case type
		case targetGUID
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
		
		try container.encode(type.rawValue, forKey: .type)
		try container.encode(targetGUID, forKey: .targetGUID)
	}
}
