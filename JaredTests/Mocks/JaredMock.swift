//
//  MockPluginManager.swift
//  JaredTests
//
//  Created by Zeke Snider on 8/1/20.
//  Copyright © 2020 Zeke Snider. All rights reserved.
//

import Foundation
import JaredFramework

// This is a mock implementation of a message sender that you can use in unit test
// Do not use this a real implementation.
class JaredMock: MessageSender {
    public var calls = [Message]()
    
    func send(_ body: String, to recipient: RecipientEntity?) {
        let me = Person(givenName: nil, handle: "", isMe: true)
        let message = Message(body: TextBody(body), date: Date(), sender: me, recipient: recipient!, attachments: [])
        send(message)
    }
    
    func send(_ message: Message) {
        calls.append(message)
    }
}
