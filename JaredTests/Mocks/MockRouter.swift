//
//  MockRouter.swift
//  JaredTests
//
//  Created by Zeke Snider on 8/3/20.
//  Copyright © 2020 Zeke Snider. All rights reserved.
//

import Foundation
import JaredFramework

class MockRouter: RouterDelegate {
    public var messages = [Message]()
    
    func route(message: Message) {
        messages.append(message)
    }
}
