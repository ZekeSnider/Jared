//
//  WebHookManager.swift
//  Jared
//
//  Created by Zeke Snider on 2/2/19.
//  Copyright © 2019 Zeke Snider. All rights reserved.
//

import Foundation
import JaredFramework

class WebHookManager: MessageDelegate {
    var urlSession: URLSession?
    var webhooks: [String]?
    
    public init(webhooks: [String]?, session: URLSessionConfiguration = URLSessionConfiguration.ephemeral) {
        self.webhooks = webhooks
        urlSession = URLSession(configuration: session)
    }
    
    public func didProcess(message: Message) {
        let webhookBody = WebHookManager.createWebhookBody(message)
        // loop over all webhooks, if the list is null, do nothing.
        for webhookBase in webhooks ?? [] {
            guard let url = URL(string: webhookBase) else {
                break
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = webhookBody
            request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            
            urlSession?.dataTask(with: request).resume()
        }
    }
    
    public func updateHooks(to hooks: [String]?) {
        self.webhooks = hooks
    }
    
    static private func createWebhookBody(_ message: Message) -> Data? {
        return try? JSONEncoder().encode(message)
    }
}
