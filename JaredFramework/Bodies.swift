//
//  Bodies.swift
//  JaredFramework
//
//  Created by Zeke Snider on 2/3/19.
//  Copyright © 2019 Zeke Snider. All rights reserved.
//

import Foundation

public protocol MessageBody: Codable {}

public struct TextBody: MessageBody, Codable {
    public var message: String
    
    public init(_ message: String) {
        self.message = message
    }
}

public struct ImageBody: MessageBody, Codable {
    public var ImagePath: String
    
    public init(_ path: String) {
        ImagePath = path
    }
}
