//
//  main.swift
//  Jared 3.0 - Swiftified
//
//  Created by Zeke Snider on 4/3/16.
//  Copyright © 2016 Zeke Snider. All rights reserved.
//

import Foundation

public func Send(_ body: String, to recipient: RecipientEntity) {
    let me = Person(givenName: nil, handle: "", isMe: true, inGroup: nil)
    let message = Message(body: TextBody(body), date: Date(), sender: me, recipient: recipient)
    Send(message, whileBlocking: false)
}

public func Send(_ message: Message, whileBlocking: Bool = false) {
    print("I want to send text \(message)")
    
    let defaults = UserDefaults.standard
    
    //Don't send the message if Jared is currently disabled.
    guard !defaults.bool(forKey: "JaredIsDisabled") else {
        return
    }
    
    var scriptPath: String?
    var recipient: String?
    var body: String?
    
    if let textBody = message.body as? TextBody {
        if message.recipient is Person {
            scriptPath = Bundle.main.url(forResource: "SendTextSingleBuddy", withExtension: "scpt")?.path
        } else if message.recipient is Group {
            scriptPath = Bundle.main.url(forResource: "SendText", withExtension: "scpt")?.path
        }
        
        recipient = message.recipient.handle
        body = textBody.message
    } else if let imageBody = message.body as? ImageBody {
        if message.recipient is Person {
            scriptPath = Bundle.main.url(forResource: "SendImageSingleBuddy", withExtension: "scpt")?.path
        } else if message.recipient is Group {
            scriptPath = Bundle.main.url(forResource: "SendImage", withExtension: "scpt")?.path
        }
        
        recipient = message.recipient.handle
        body = imageBody.ImagePath
    }
    
    if scriptPath != nil && recipient != nil && body != nil {
        let task = Process()
        task.launchPath = "/usr/bin/osascript"
        task.arguments = [scriptPath!, body!, recipient!]
        task.launch()
        if whileBlocking {
            task.waitUntilExit()
            Thread.sleep(forTimeInterval: Double(5))
        }
    }
}

public enum Compare {
    case startsWith
    case contains
    case `is`
    case containsURL
}

public protocol RoutingModule {
    var routes: [Route] {get}
    var description: String {get}
    init()
}

public protocol RecipientEntity: Codable {
    var handle: String {get set}
}
public protocol SenderEntity: Codable {
    var handle: String {get set}
    var givenName: String? {get set}
}
public protocol MessageBody: Codable {}

public struct TextBody: MessageBody, Codable {
    public var message: String
    
    public init(_ inMessage: String) {
        message = inMessage
    }
}

public struct ImageBody: MessageBody, Codable {
    public var ImagePath: String
}

public struct Person: SenderEntity, RecipientEntity, Codable {
    public var givenName: String?
    public var handle: String
    public var isMe: Bool = false
    public var inGroup: Group?
    
    public init(givenName: String?, handle: String, isMe: Bool, inGroup: Group?) {
        self.givenName = givenName
        self.handle = handle
        self.isMe = isMe
        self.inGroup = inGroup
    }
}

public struct Group: RecipientEntity, Codable {
    public var name: String?
    public var handle: String
    public var participants: [Person]
    
    public init(name: String?, handle: String, participants: [Person]) {
        self.name = name
        self.handle = handle
        self.participants = participants
    }
}

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

public struct Route {
    public var name: String
    public var comparisons: [Compare: [String]]
    public var parameterSyntax: String?
    public var description: String?
    public var call: (Message) -> Void
    
    public init(name: String, comparisons:[Compare: [String]], call: @escaping (Message) -> Void) {
        self.name = name
        self.comparisons = comparisons
        self.call = call
    }
    public init(name: String, comparisons:[Compare: [String]], call: @escaping (Message) -> Void, description: String) {
        self.name = name
        self.comparisons = comparisons
        self.call = call
        self.description = description
    }
    public init(name: String, comparisons:[Compare: [String]], call: @escaping (Message) -> Void, description: String, parameterSyntax: String) {
        self.name = name
        self.comparisons = comparisons
        self.call = call
        self.description = description
        self.parameterSyntax = parameterSyntax
    }
}

public func getAppSupportDirectory() -> URL{
    let appsupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
    return appsupport.appendingPathComponent("Jared")
}

public func matchesForRegexInText(_ regex: String!, text: String!) -> [String] {
    do {
        let regex = try NSRegularExpression(pattern: regex, options: [NSRegularExpression.Options.caseInsensitive])
        let nsString = text as NSString
        let results = regex.matches(in: text,
                                            options: [], range: NSMakeRange(0, nsString.length))
        return results.map { nsString.substring(with: $0.range)}
    } catch let error as NSError {
        print("invalid regex: \(error.localizedDescription)")
        return []
    }
}
