//
//  Router.swift
//  Jared
//
//  Created by Zeke Snider on 4/20/20.
//  Copyright © 2020 Zeke Snider. All rights reserved.
//

import Foundation
import JaredFramework

class Router {
    var pluginManager: PluginManagerDelegate
    var messageDelegates: [MessageDelegate]
    
    init(pluginManager: PluginManagerDelegate, messageDelegates: [MessageDelegate]) {
        self.pluginManager = pluginManager
        self.messageDelegates = messageDelegates
    }
    
    func route(message myMessage: Message) {
        messageDelegates.forEach { delegate in delegate.didProcess(message: myMessage) }
        
        // Currently don't process any images
        guard let messageText = myMessage.body as? TextBody else {
            return
        }
        
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let matches = detector.matches(in: messageText.message, options: [], range: NSMakeRange(0, messageText.message.count))
        let myLowercaseMessage = messageText.message.lowercased()
        
        let defaults = UserDefaults.standard
        
        guard !defaults.bool(forKey: "JaredIsDisabled") || myLowercaseMessage == "/enable" else {
            return
        }
        
        RootLoop: for aModule in pluginManager.getAllModules() {
            for aRoute in aModule.routes {
                guard (pluginManager.enabled(routeName: aRoute.name)) else {
                    break
                }
                for aComparison in aRoute.comparisons {
                    if aComparison.0 == .containsURL {
                        for match in matches {
                            let url = (messageText.message as NSString).substring(with: match.range)
                            for comparisonString in aComparison.1 {
                                if url.contains(comparisonString) {
                                    let urlMessage = Message(body: TextBody(url), date: myMessage.date ?? Date(), sender: myMessage.sender, recipient: myMessage.recipient, attachments: [])
                                    aRoute.call(urlMessage)
                                }
                            }
                        }
                    }
                        
                    else if aComparison.0 == .startsWith {
                        for comparisonString in aComparison.1 {
                            if myLowercaseMessage.hasPrefix(comparisonString.lowercased()) {
                                aRoute.call(myMessage)
                                break RootLoop
                            }
                        }
                    }
                        
                    else if aComparison.0 == .contains {
                        for comparisonString in aComparison.1 {
                            if myLowercaseMessage.contains(comparisonString.lowercased()) {
                                aRoute.call(myMessage)
                                break RootLoop
                            }
                        }
                    }
                        
                    else if aComparison.0 == .is {
                        for comparisonString in aComparison.1 {
                            if myLowercaseMessage == comparisonString.lowercased() {
                                aRoute.call(myMessage)
                                break RootLoop
                            }
                        }
                    }
                }
            }
        }
    }
}
