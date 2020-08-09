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
        if let configurationMapping = Configuration.shared.parameters?.actionType[actionTypeInt] {
            self.init(rawValue: configurationMapping)!
        } else {
            self = .unknown
        }
    }
}
