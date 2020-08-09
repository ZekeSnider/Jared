//
//  main.swift
//  Jared 3.0 - Swiftified
//
//  Created by Zeke Snider on 4/3/16.
//  Copyright © 2016 Zeke Snider. All rights reserved.
//

import Foundation

public struct Message: Encodable {
    public var body: MessageBody?
    public var date: Date?
    public var sender: SenderEntity
    public var recipient: RecipientEntity
    public var attachments: [Attachment]?
    public var sendStyle: SendStyle
    public var action: Action?
    public var guid: String?
    
    enum CodingKeys : String, CodingKey{
        case date
        case body
        case sender
        case recipient
        case attachments
        case sendStyle
        case action
        case guid
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var recipientCopy = recipient
        
        if let textBody = body as? TextBody {
            try container.encode(textBody, forKey: .body)
        }
        
        if let person = sender as? Person {
            try container.encode(person, forKey: .sender)
        }
        
        if let abstractRecipient = recipient as? AbstractRecipient {
            recipientCopy = abstractRecipient.getSpecificEntity()
        }
        
        if let person = recipientCopy as? Person {
            try container.encode(person, forKey: .recipient)
        } else if let group = recipientCopy as? Group {
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
        try container.encode(guid, forKey: .guid)
        
        if (action != nil) {
            try container.encode(action, forKey: .action)
        }
    }
    
    public init (body: MessageBody?, date: Date, sender: SenderEntity, recipient: RecipientEntity, guid: String? = nil, attachments: [Attachment] = [], sendStyle: String? = nil, associatedMessageType: Int? = nil, associatedMessageGUID: String? = nil) {
        self.body = body
        self.recipient = recipient
        self.sender = sender
        self.date = date
        self.attachments = attachments
        self.sendStyle = SendStyle(fromIdentifier: sendStyle)
        self.guid = guid
        
        if (associatedMessageType != 0 && associatedMessageGUID != nil) {
            self.action = Action(actionTypeInt: associatedMessageType!, targetGUID: associatedMessageGUID!.replacingOccurrences(of: "p:0/", with: ""))
        }
    }
    
    public func RespondTo() -> RecipientEntity? {
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
        return nil
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
}
