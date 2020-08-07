//
//  MessageTests.swift
//  JaredTests
//
//  Created by Zeke Snider on 2/3/19.
//  Copyright © 2019 Zeke Snider. All rights reserved.
//

import XCTest
import JaredFramework

class GlobalTest: XCTestCase {
    override func setUp() {
    }
    
    override func tearDown() {
    }
    
    func testFromActionTypeInt() {
        let anArray = [1, 2, 3, 4]
        
        let inBound = anArray[safe: 1]
        XCTAssertEqual(inBound, 2, "In bound property returns value")
        let outOfBounds = anArray[safe: 4]
        XCTAssertEqual(outOfBounds, nil, "Out of bounds array access returns nil")
    }
}
