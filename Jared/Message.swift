//
//  main.swift
//  Jared 3.0 - Swiftified
//
//  Created by Zeke Snider on 4/3/16.
//  Copyright © 2016 Zeke Snider. All rights reserved.
//

import Foundation

public struct Message: Encodable {
    public var body: MessageBody
    public var date: Date?
    public var sender: SenderEntity
    public var recipient: RecipientEntity
	public var attachments: [Attachment]
	public var sendStyle: SendStyle
	public var action: Action?
    
    enum CodingKeys : String, CodingKey{
        case date
        case body
        case sender
        case recipient
		case attachments
		case sendStyle
		case action
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        if let textBody = body as? TextBody {
            try container.encode(textBody, forKey: .body)
        } else if let imageBody = body as? ImageBody {
            try container.encode(imageBody, forKey: .body)
        }
        
        if let person = sender as? Person {
            try container.encode(person, forKey: .sender)
        }
        
        if let person = recipient as? Person {
            try container.encode(person, forKey: .recipient)
        } else if let group = recipient as? Group {
            try container.encode(group, forKey: .recipient)
        }
        
        if let notOptionalDate = date {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            formatter.locale = Locale(identifier: "en_US_POSIX")
            
            try container.encode(formatter.string(from: notOptionalDate), forKey: .date)
        }
		
		try container.encode(sendStyle.rawValue, forKey: .sendStyle)
		try container.encode(attachments, forKey: .attachments)
		
		if (action != nil) {
			try container.encode(action, forKey: .action)
		}
    }
    
	public init (body: MessageBody, date: Date, sender: SenderEntity, recipient: RecipientEntity, attachments: [Attachment] = [], sendStyle: String? = nil, associatedMessageType: Int? = nil, associatedMessageGUID: String? = nil) {
        self.body = body
        self.recipient = recipient
        self.sender = sender
        self.date = date
		self.attachments = attachments
		self.sendStyle = Message.getSendStyle(from: sendStyle)
		
		if (associatedMessageType != 0 && associatedMessageGUID != nil) {
			self.action = Action(type: Message.getActionType(from: associatedMessageType!), targetGUID: associatedMessageGUID!)
		}
    }
	
	private static func getActionType(from actionTypeInt: Int) -> ActionType {
		switch(actionTypeInt) {
		case 2005:
			return .question
		default:
			return .unknown
		}
	}
	
	private static func getSendStyle(from sendStyleString: String?) -> SendStyle {
		guard let sendStyleString = sendStyleString else { return .regular }
		switch(sendStyleString) {
		case "com.apple.messages.effect.CKShootingStarEffect":
			return .shootingStar
		case "com.apple.messages.effect.CKLasersEffect":
			return .lasers
		case "com.apple.messages.effect.CKHeartEffect":
			return .love
		case "com.apple.messages.effect.CKHappyBirthdayEffect":
			return .confetti
		case "com.apple.messages.effect.CKFireworksEffect":
			return .fireworks
		case "com.apple.messages.effect.CKConfettiEffect":
			return .confetti
		case "com.apple.MobileSMS.expressivesend.loud":
			return .loud
		case "com.apple.MobileSMS.expressivesend.invisibleink":
			return .invisibleInk
		case "com.apple.MobileSMS.expressivesend.gentle":
			return .gentle
		case "com.apple.messages.effect.CKEchoEffect":
			return .echo
		case "com.apple.MobileSMS.expressivesend.impact":
			return .slam
		default:
			return .unknown
		}
	}
    
    public func RespondTo() -> RecipientEntity {
        if let senderPerson = sender as? Person {
            if (senderPerson.isMe) {
                if let person = recipient as? Person {
                    return person
                } else if let group = recipient as? Group {
                    return group
                }
            } else {
                if let group = recipient as? Group {
                    return group
                } else {
                    return senderPerson
                }
            }
        }
        
        NSLog("Couldn't coerce respond to entity properly.")
        return Person(givenName: nil, handle: "", isMe: false)
    }
    
    public func getTextBody() -> String? {
        guard let body = self.body as? TextBody else {
            return nil
        }
        
        return body.message
    }
    
    public func getTextParameters() -> [String]? {
        return self.getTextBody()?.components(separatedBy: ",")
    }
    
    public func getImageBody() -> String? {
        guard let body = self.body as? ImageBody else {
            return nil
        }
        
        return body.ImagePath
    }
}
