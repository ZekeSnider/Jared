//
//  main.swift
//  Jared 3.0 - Swiftified
//
//  Created by Zeke Snider on 4/3/16.
//  Copyright © 2016 Zeke Snider. All rights reserved.
//

import Foundation

public enum ActionType: String {
    case like = "like"
    case love = "love"
    case laugh = "laugh"
    case exclaim = "exclaim"
    case question = "question"
    case unknown = "unknown"
    
    public init(fromActionTypeInt actionTypeInt: Int) {
        switch(actionTypeInt) {
        case 2005:
            self = .question
        default:
            self = .unknown
        }
    }
}

public struct Action: Encodable {
	public var type: ActionType
	public var targetGUID: String
	
	enum CodingKeys : String, CodingKey{
        case type
		case targetGUID
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
		
		try container.encode(type.rawValue, forKey: .type)
		try container.encode(targetGUID, forKey: .targetGUID)
	}
}
