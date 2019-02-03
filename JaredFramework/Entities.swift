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
