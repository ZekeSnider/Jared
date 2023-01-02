//
//  Entities.swift
//  JaredFramework
//
//  Created by Zeke Snider on 2/3/19.
//  Copyright © 2019 Zeke Snider. All rights reserved.
//

import Foundation

public protocol Entity: Codable {
    var handle: String {get set}
}

extension Entity {
    public func isGroupHandle() -> Bool {
        return handle.contains(";+;") || handle.contains(";-;")
    }
}

public protocol RecipientEntity: Entity, Codable {
}
public protocol SenderEntity: Entity, Codable {
    var givenName: String? {get set}
}

// This represents an entity which could either be a person or a group
// Use this if you have a handle but don't know what type it is.
// If you know the type, please construct a group or person directly.
public struct AbstractRecipient: RecipientEntity, Codable, Equatable {
    public var handle: String
    
    public init(handle: String) {
        self.handle = handle
    }
    
    public func getSpecificEntity() -> RecipientEntity {
        if isGroupHandle() {
            return Group(name: nil, handle: handle, participants: [])
        } else {
            return Person(handle: handle)
        }
    }
}

public struct Person: SenderEntity, RecipientEntity, Codable, Equatable {
    public var givenName: String?
    public var handle: String
    public var isMe: Bool = false
    
    enum CodingKeys : String, CodingKey{
        case handle
        case givenName
        case isMe
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
