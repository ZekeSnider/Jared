//
//  MockPluginManager.swift
//  JaredTests
//
//  Created by Zeke Snider on 8/1/20.
//  Copyright © 2020 Zeke Snider. All rights reserved.
//

import Foundation
import JaredFramework

class JaredMock: MessageSender {
    public var calls = [Message]()
    
    func Send(_ body: String, to recipient: RecipientEntity) {
        let me = Person(givenName: nil, handle: "", isMe: true)
        let message = Message(body: TextBody(body), date: Date(), sender: me, recipient: recipient, attachments: [])
        Send(message)
    }
    
    func Send(_ message: Message) {
        calls.append(message)
    }
}
