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
    case dislike = "dislike"
    case love = "love"
    case laugh = "laugh"
    case exclaim = "exclaim"
    case question = "question"
    case unknown = "unknown"
    
    public init(fromActionTypeInt actionTypeInt: Int) {
        switch(actionTypeInt) {
        case 2000:
            self = .love
        case 2001:
            self = .like
        case 2002:
            self = .dislike
        case 2003:
            self = .laugh
        case 2004:
            self = .exclaim
        case 2005:
            self = .question
        default:
            self = .unknown
        }
    }
}
