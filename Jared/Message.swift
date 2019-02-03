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
    
    enum CodingKeys : String, CodingKey{
        case date
        case body
        case sender
        case recipient
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
    }
    
    public init (body: MessageBody, date: Date, sender: SenderEntity, recipient: RecipientEntity) {
        self.body = body
        self.recipient = recipient
        self.sender = sender
        self.date = date
    }
    
    // Easily flip a message around to respond to it
    init (message: Message, newBody: MessageBody, me: Person) {
        body = newBody
        
        let person = message.sender as! Person
        
        // If the person sent in a group,
        // we should respond to the group.
        if let group = person.inGroup {
            recipient = group
        } else {
            recipient = person
        }
        
        sender = me
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
        return Person(givenName: nil, handle: "", isMe: false, inGroup: nil)
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
