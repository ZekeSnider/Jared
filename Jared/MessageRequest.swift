//
//  MessageRequest.swift
//  Jared
//
//  Created by Zeke Snider on 12/28/19.
//  Copyright © 2019 Zeke Snider. All rights reserved.
//

import Foundation
import JaredFramework

// Struct that defines what parameters are accepted in requests
public struct MessageRequest: Decodable {
    public var body: MessageBody
    public var recipient: RecipientEntity
    
    enum CodingKeys : String, CodingKey {
        case body
        case recipient
    }
    
    enum ParameterError: Error {
        case runtimeError(String)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let textBody = try? container.decode(TextBody.self, forKey: .body) {
            self.body = textBody
        } else {
            throw ParameterError.runtimeError("the body parameter is incorrectly formatted")
        }
        
        if let person = try? container.decode(Person.self, forKey: .recipient) {
            self.recipient = person
        } else if let group = try? container.decode(Group.self, forKey: .recipient) {
            self.recipient = group
        } else {
            throw ParameterError.runtimeError("the recipient parameter is incorrectly formatted")
        }
    }
}
