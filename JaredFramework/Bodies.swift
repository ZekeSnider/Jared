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

public struct Attachment: Codable {
    public var id: Int?
    public var filePath: String
    public var mimeType: String?
    public var fileName: String?
    public var isSticker: Bool?
    
    public init(id: Int, filePath: String, mimeType: String, fileName: String, isSticker: Bool) {
        self.id = id
        self.filePath = filePath
        self.mimeType = mimeType
        self.fileName = fileName
        self.isSticker = isSticker
    }
}
