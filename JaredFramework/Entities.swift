//
//  Entities.swift
//  JaredFramework
//
//  Created by Zeke Snider on 2/3/19.
//  Copyright © 2019 Zeke Snider. All rights reserved.
//

import Foundation

public protocol RecipientEntity: Codable {
    var handle: String {get set}
}
public protocol SenderEntity: Codable {
    var handle: String {get set}
    var givenName: String? {get set}
}

public struct Person: SenderEntity, RecipientEntity, Codable, Equatable {
    public var givenName: String?
    public var handle: String
    public var isMe: Bool = false
    
    enum CodingKeys : String, CodingKey{
        case handle
    }
    
    public init(handle: String) {
        self.handle = handle
    }
    
    public init(givenName: String?, handle: String, isMe: Bool?) {
        self.givenName = givenName
        self.handle = handle
        self.isMe = isMe ?? false
    }
    
    public static func == (lhs: Person, rhs: Person) -> Bool {
        return lhs.givenName == rhs.givenName &&
            lhs.handle == rhs.handle &&
            lhs.isMe == rhs.isMe
    }
}

public struct Group: RecipientEntity, Codable, Equatable {
    public var name: String?
    public var handle: String
    public var participants: [Person]
    
    public init(name: String?, handle: String, participants: [Person]) {
        self.name = name
        self.handle = handle
        self.participants = participants
    }
    
    public static func == (lhs: Group, rhs: Group) -> Bool {
        return lhs.name == rhs.name &&
            lhs.handle == rhs.handle &&
            lhs.participants == rhs.participants
    }
}
