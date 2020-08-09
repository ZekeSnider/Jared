//
//  MessageSender.swift
//  Jared
//
//  Created by Zeke Snider on 8/6/20.
//  Copyright © 2020 Zeke Snider. All rights reserved.
//

import Foundation

public protocol MessageSender {
    func send(_ body: String, to recipient: RecipientEntity?)
    func send(_ message: Message)
}
