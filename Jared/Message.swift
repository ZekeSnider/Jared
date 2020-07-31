//
//  main.swift
//  Jared 3.0 - Swiftified
//
//  Created by Zeke Snider on 4/3/16.
//  Copyright © 2016 Zeke Snider. All rights reserved.
//

import Foundation

public struct Action: Encodable {
	public var type: ActionType
	
	enum CodingKeys : String, CodingKey{
        case type
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
		
		try container.encode(type.hashValue, forKey: .type)
	}
}

public enum ActionType {
	case like
	case love
	case laugh
	case exclaim
	case question
}

public enum SendStyle {
	case regular
	case slam
	case loud
	case gentle
	case invisibleInk
	case echo
	case spotlight
	case balloons
	case confetti
	case love
	case lasers
	case fireworks
	case shootingStar
	case celebration
}

public struct Message: Encodable {
    public var body: MessageBody
    public var date: Date?
    public var sender: SenderEntity
    public var recipient: RecipientEntity
	public var attachments: [Attachment]
    
    enum CodingKeys : String, CodingKey{
        case date
        case body
        case sender
        case recipient
		case attachments
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
		
		try container.encode(attachments, forKey: .attachments)
    }
    
	public init (body: MessageBody, date: Date, sender: SenderEntity, recipient: RecipientEntity, attachments: [Attachment]) {
        self.body = body
        self.recipient = recipient
        self.sender = sender
        self.date = date
		self.attachments = attachments
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
