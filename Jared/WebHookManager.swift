//
//  WebHookManager.swift
//  Jared
//
//  Created by Zeke Snider on 2/2/19.
//  Copyright © 2019 Zeke Snider. All rights reserved.
//

import Foundation
import JaredFramework

class WebHookManager: MessageDelegate, RoutingModule {
    var urlSession: URLSession
    var webhooks = [Webhook]()
    var routes = [Route]()
    var sender: MessageSender
    var description = "Routes provided by webhooks"
    
    
    public init(webhooks: [Webhook]?, session: URLSessionConfiguration = URLSessionConfiguration.ephemeral, sender: MessageSender) {
        self.sender = sender
        urlSession = URLSession(configuration: session)
        
        updateHooks(to: webhooks)
    }
    
    required convenience init(sender: MessageSender) {
        self.init(webhooks: nil, session: URLSessionConfiguration.ephemeral, sender: sender)
    }
    
    public func didProcess(message: Message) {
        // loop over all webhooks, if the list is null, do nothing.
        for webhook in webhooks {
            // if a webhook has routes, we shouldn't call it for every message
            guard webhook.routes?.count == 0 else {
                break
            }
            
            notifyRoute(message, url: webhook.url)
        }
    }
    
    public func notifyRoute(_ message: Message, url: String) {
        guard let parsedUrl = URL(string: url) else {
            return
        }
        let webhookBody = WebHookManager.createWebhookBody(message)
        
        var request = URLRequest(url: parsedUrl)
        request.httpMethod = "POST"
        request.httpBody = webhookBody
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        urlSession.dataTask(with: request).resume()
    }
    
    public func updateHooks(to hooks: [Webhook]?) {
        self.webhooks = (hooks ?? []).map({ (hook) -> Webhook in
            var newHook = hook
            newHook.routes = (newHook.routes ?? []).map({ (route) -> Route in
                var newRoute = route
                newRoute.call = {[weak self] in
                    self?.notifyRoute($0, url: newHook.url)
                }
                return newRoute
            })
            
            return newHook
        })
        
        self.routes = self.webhooks.flatMap({ $0.routes ?? [] })
    }

    static private func createWebhookBody(_ message: Message) -> Data? {
        return try? JSONEncoder().encode(message)
    }
}
