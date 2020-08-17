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
    let queue = OperationQueue()
    
    init() {
        queue.maxConcurrentOperationCount = 1
    }
    
    public func send(_ body: String, to recipient: RecipientEntity?) {
        guard var recipient = recipient else {
            return
        }
        if let abstract = recipient as? AbstractRecipient {
            recipient = abstract.getSpecificEntity()
        }
        
        let me = Person(givenName: nil, handle: "", isMe: true)
        let message = Message(body: TextBody(body), date: Date(), sender: me, recipient: recipient, attachments: [])
        send(message)
    }
    
    public func send(_ message: Message) {
        NSLog("Attemping to send message: \(message)")
        
        let defaults = UserDefaults.standard
        
        //Don't send the message if Jared is currently disabled.
        guard !defaults.bool(forKey: JaredConstants.jaredIsDisabled) else {
            return
        }
        
        let recipient = message.recipient.handle
        
        if let textBody = message.body as? TextBody {
            var scriptPath: String?
            let body = textBody.message
            
            if #available(OSX 10.16, *) {
                scriptPath = Bundle.main.url(forResource: "SendTextUI", withExtension: "scpt")?.path
            } else {
                if message.recipient.handle.contains(";+;") {
                    scriptPath = Bundle.main.url(forResource: "SendText", withExtension: "scpt")?.path
                } else {
                    scriptPath = Bundle.main.url(forResource: "SendTextSingleBuddy", withExtension: "scpt")?.path
                }
            }
            
            queue.addOperation {
                self.executeScript(scriptPath: scriptPath, body: body, recipient: recipient)
            }
        }
        
        if let attachments = message.attachments {
            var scriptPath: String?
            
            if message.recipient.handle.contains(";+;") {
                scriptPath = Bundle.main.url(forResource: "SendImage", withExtension: "scpt")?.path
            } else {
                scriptPath = Bundle.main.url(forResource: "SendImageSingleBuddy", withExtension: "scpt")?.path
            }
            
            attachments.forEach{attachment in
                queue.addOperation {
                    self.executeScript(scriptPath: scriptPath, body: attachment.filePath, recipient: recipient)
                }
            }
        }
    }
    
    private func executeScript(scriptPath: String?, body: String?, recipient: String?) {
        guard(scriptPath != nil && body != nil && recipient != nil) else {
            return
        }
        
        let task = Process()
        task.launchPath = "/usr/bin/osascript"
        task.arguments = [scriptPath!, body!, recipient!]
        task.launch()
        task.waitUntilExit()
    }
}

