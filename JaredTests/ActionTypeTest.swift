//
//  MessageTests.swift
//  JaredTests
//
//  Created by Zeke Snider on 2/3/19.
//  Copyright © 2019 Zeke Snider. All rights reserved.
//

import XCTest
import JaredFramework

class ActionTypeTest: XCTestCase {
    override func setUp() {
    }
    
    override func tearDown() {
    }
    
    func testFromActionTypeInt() {
        XCTAssertEqual(ActionType(fromActionTypeInt: 2005), .question, "Properly deserializes known action type")
        
        XCTAssertEqual(ActionType(fromActionTypeInt: 696969), .unknown, "Properly deserializes unknown action type")
    }
}
