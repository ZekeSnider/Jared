//
//  MessageTests.swift
//  JaredTests
//
//  Created by Zeke Snider on 2/3/19.
//  Copyright © 2019 Zeke Snider. All rights reserved.
//

import XCTest
import JaredFramework

class ActionTest: XCTestCase {
    static let removeLikeJSON = "{\"type\":\"like\",\"targetGUID\":\"goodGUID\",\"event\":\"removed\"}"
    static let placeLoveJSON = "{\"type\":\"love\",\"targetGUID\":\"goodGUID\",\"event\":\"placed\"}"
    override func setUp() {
    }
    
    override func tearDown() {
    }
    
    func testFromActionTypeInt() {
        let targetGUID = "goodGUID"
        let encoder = JSONEncoder()
        var action = Action(actionTypeInt: 3001, targetGUID: targetGUID)
        
        XCTAssertEqual(action.event, .removed, "Event marked as removed")
        XCTAssertEqual(action.type, .like, "Type is correct")
        XCTAssertEqual(String(data: try! encoder.encode(action), encoding: .utf8),
                       ActionTest.removeLikeJSON, "Encoding works as expected")
        
        action = Action(actionTypeInt: 2000, targetGUID: targetGUID)
        
        XCTAssertEqual(action.event, .placed, "Event marked as removed")
        XCTAssertEqual(action.type, .love, "Type is correct")
        XCTAssertEqual(String(data: try! encoder.encode(action), encoding: .utf8),
                       ActionTest.placeLoveJSON, "Encoding works as expected")
    }
}
