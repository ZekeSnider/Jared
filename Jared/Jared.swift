//
//  Jared.swift
//  JaredFramework
//
//  Created by Zeke Snider on 2/3/19.
//  Copyright © 2019 Zeke Snider. All rights reserved.
//

import Foundation
import JaredFramework

public class Jared: MessageSender {
    public func Send(_ body: String, to recipient: RecipientEntity?) {
        guard let recipient = recipient else {
            return
        }
        let me = Person(givenName: nil, handle: "", isMe: true)
        let message = Message(body: TextBody(body), date: Date(), sender: me, recipient: recipient, attachments: [])
        Send(message)
    }
    
    public func Send(_ message: Message) {
        NSLog("Attemping to send message: \(message)")
        
        let defaults = UserDefaults.standard
        
        //Don't send the message if Jared is currently disabled.
        guard !defaults.bool(forKey: "JaredIsDisabled") else {
            return
        }
        
        var scriptPath: String?
        var recipient: String?
        var body: String?
        
        if let textBody = message.body as? TextBody {
            if #available(OSX 10.16, *) {
                scriptPath = Bundle.main.url(forResource: "SendTextUI", withExtension: "scpt")?.path
            } else {
                if message.recipient is Person {
                    scriptPath = Bundle.main.url(forResource: "SendTextSingleBuddy", withExtension: "scpt")?.path
                } else if message.recipient is Group {
                    scriptPath = Bundle.main.url(forResource: "SendText", withExtension: "scpt")?.path
                }
            }
            
            recipient = message.recipient.handle
            body = textBody.message
        }
        
        if scriptPath != nil && recipient != nil && body != nil {
            let task = Process()
            task.launchPath = "/usr/bin/osascript"
            task.arguments = [scriptPath!, body!, recipient!]
            task.launch()
            
            // Big Sur and later have to use UI scripting,
            // so we need to block the thread.
            if #available(OSX 10.16, *) {
                task.waitUntilExit()
            }
        }
    }
}

