//
//  MessageTests.swift
//  JaredTests
//
//  Created by Zeke Snider on 2/3/19.
//  Copyright © 2019 Zeke Snider. All rights reserved.
//

import XCTest
import JaredFramework

class SendStyleTest: XCTestCase {
    override func setUp() {
    }
    
    override func tearDown() {
    }
    
    func testFromSendStyleIdentifier() {
        XCTAssertEqual(SendStyle(fromIdentifier: nil), .regular, "Properly accept nil action type")
        
        XCTAssertEqual(SendStyle(fromIdentifier: "com.apple.messages.effect.CKShootingStarEffect"), .shootingStar, "Properly deserializes shooting star action type")
        
        XCTAssertEqual(SendStyle(fromIdentifier: "com.apple.MobileSMS.expressivesend.impact"), .slam, "Properly deserializes impact action type")
        
        XCTAssertEqual(SendStyle(fromIdentifier: "com.zeke.unknown"), .unknown, "Properly deserializes unknown action type")
    }
}
