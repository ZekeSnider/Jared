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
        session.timeoutIntervalForResource = 10.0
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
        NSLog("Notifying \(url) of new message event")
        
        guard let parsedUrl = URL(string: url) else {
            NSLog("Unable to parse URL for webhook \(url)")
            return
        }
        let webhookBody = WebHookManager.createWebhookBody(message)
        
        var request = URLRequest(url: parsedUrl)
        request.httpMethod = "POST"
        request.httpBody = webhookBody
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        urlSession.dataTask(with: request) { data, response, error in
            guard error == nil, let data = data, let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200 else {
                NSLog("Received error while requesting webhook \(error.debugDescription)")
                return
            }
            guard let decoded = try? JSONDecoder().decode(WebhookResponse.self, from: data) else {
                NSLog("Unable to parse response from webhook")
                return
            }
            
            if (decoded.success) {
                if let decodedBody = decoded.body?.message {
                    self.sender.send(decodedBody, to: message.RespondTo())
                }
            } else {
                if let decodedError = decoded.error {
                    NSLog("Got back error from webhook. \(decodedError)")
                    return
                }
            }
        }.resume()
    }
    
    public func updateHooks(to hooks: [Webhook]?) {
        // Change all routes to have a callback that calls the webhook manager's
        // notify route method
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
        NSLog("Webhooks updated to: \(self.webhooks.map{ $0.url }.joined(separator: ", "))")
    }

    static private func createWebhookBody(_ message: Message) -> Data? {
        return try? JSONEncoder().encode(message)
    }
}
