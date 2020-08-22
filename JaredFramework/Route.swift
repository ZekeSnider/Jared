//
//  Route.swift
//  JaredFramework
//
//  Created by Zeke Snider on 2/3/19.
//  Copyright © 2019 Zeke Snider. All rights reserved.
//

import Foundation

public enum Compare: String, Codable {
    case startsWith
    case contains
    case `is`
    case containsURL
    case isReaction
}

public struct Route: Decodable {
    public var name: String
    public var comparisons: [Compare: [String]]
    public var parameterSyntax: String?
    public var description: String?
    public var call: (Message) -> Void
    
    enum CodingKeys : String, CodingKey {
        case name
        case comparisons
        case parameterSyntax
        case description
    }
    
    public init(name: String, comparisons:[Compare: [String]], call: @escaping (Message) -> Void) {
        self.name = name
        self.comparisons = comparisons
        self.call = call
    }
    public init(name: String, comparisons:[Compare: [String]], call: @escaping (Message) -> Void, description: String) {
        self.name = name
        self.comparisons = comparisons
        self.call = call
        self.description = description
    }
    public init(name: String, comparisons:[Compare: [String]], call: @escaping (Message) -> Void, description: String, parameterSyntax: String) {
        self.name = name
        self.comparisons = comparisons
        self.call = call
        self.description = description
        self.parameterSyntax = parameterSyntax
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.comparisons = try container.decode([Compare: [String]].self, forKey: .comparisons)
        self.description = try container.decode(String.self, forKey: .description)
        self.parameterSyntax = try container.decode(String.self, forKey: .parameterSyntax)
        
        self.call = { _ in }
    }
}

public protocol RoutingModule {
    var routes: [Route] {get}
    var description: String {get}
    init(sender: MessageSender)
}


public extension KeyedDecodingContainer  {
    func decode(_ type: [Compare: [String]].Type, forKey key: Key) throws -> [Compare: [String]] {
        let stringDictionary = try self.decode([String: [String]].self, forKey: key)
        var dictionary = [Compare: [String]]()

        for (key, value) in stringDictionary {
            guard let anEnum = Compare(rawValue: key) else {
                let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Could not parse json key to an Compare object")
                throw DecodingError.dataCorrupted(context)
            }
            dictionary[anEnum] = value
        }

        return dictionary
    }
}
