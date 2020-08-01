//
//  MessageTests.swift
//  JaredTests
//
//  Created by Zeke Snider on 2/3/19.
//  Copyright © 2019 Zeke Snider. All rights reserved.
//

import XCTest
import JaredFramework

class RouterTests: XCTestCase {
    let mockPluginManager = MockPluginManager()
    var router: Router!
	
    static let startsWithMessage = Message(body: TextBody("\(startWithString) some text after it"), date: Date(), sender: swiftPerson, recipient: mePerson)
    static let containsMessage = Message(body: TextBody("some text before \(containsString) some text after it"), date: Date(), sender: swiftPerson, recipient: mePerson)
	
    static let mePerson = Person(givenName: "zeke", handle: "zeke@email.com", isMe: true)
    static let swiftPerson = Person(givenName: "taylor", handle: "taylor@swift.org", isMe: false)

    override func setUp() {
		router = Router(pluginManager: mockPluginManager, messageDelegates: [])
    }

    override func tearDown() {
    }
	
	func testDisable() {
		// Does start with
		router.route(message: RouterTests.startsWithMessage)
		XCTAssert(mockPluginManager.callCounts[startWithString] == 1, "Starts with delegate properly called")
		
		// Disable it
		mockPluginManager.toggleDisable(routeName: startWithString)
		router.route(message: RouterTests.startsWithMessage)
		XCTAssert(mockPluginManager.callCounts[startWithString] == 1, "Starts with delegate not called")
		
		// Enable it again
		mockPluginManager.toggleDisable(routeName: startWithString)
		router.route(message: RouterTests.startsWithMessage)
		XCTAssert(mockPluginManager.callCounts[startWithString] == 2, "Starts with delegate properly called")
	}
	
	func testStartsWith() {
		// Does start with
		router.route(message: RouterTests.startsWithMessage)
		XCTAssert(mockPluginManager.callCounts[startWithString] == 1, "Starts with delegate properly called")
		
		// Does not start with
		let doesNotStartWith = Message(body: TextBody("Some random unrelated text."), date: Date(), sender: RouterTests.swiftPerson, recipient: RouterTests.mePerson)
		router.route(message: doesNotStartWith)
		XCTAssert(mockPluginManager.callCounts[startWithString] == 1, "Starts with delegate was not called")
	}
    
    func testContains() {
        // Does contain
        router.route(message: RouterTests.containsMessage)
        XCTAssert(mockPluginManager.callCounts[containsString] == 1, "Contains delegate properly called")
        
        // Does not contain
        let doesNotContain = Message(body: TextBody("Some random unrelated text."), date: Date(), sender: RouterTests.swiftPerson, recipient: RouterTests.mePerson)
        router.route(message: doesNotContain)
        XCTAssert(mockPluginManager.callCounts[containsString] == 1, "Contains delegate was not called")
    }
}