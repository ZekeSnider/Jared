//
//  MessageTests.swift
//  JaredTests
//
//  Created by Zeke Snider on 2/3/19.
//  Copyright © 2019 Zeke Snider. All rights reserved.
//

import XCTest
import JaredFramework

let startWithString = "/startWith"
let containsString = "/contains"

class MockPluginManager: PluginManagerDelegate {
	var callCounts = [String: Int]()
	var disabled = [String: Bool]()
	
	func getAllRoutes() -> [Route] {
		let startWith = Route(name: startWithString, comparisons: [.startsWith: [startWithString]], call: {(message: Message) -> Void in self.increment(routeName: startWithString)}, description: "")
		let contains = Route(name: containsString, comparisons: [.contains: [containsString]], call: {(message) -> Void in self.increment(routeName: containsString)}, description: "")
		
		return [startWith, contains]
	}
	
	func getAllModules() -> [RoutingModule] {
		return []
	}
	
	func reload() {
	}
	
	func enabled(routeName: String) -> Bool {
		return disabled[routeName, default: true]
	}
	
	func toggleDisable(routeName: String) -> Void {
		disabled[routeName] = !disabled[routeName, default: true]
	}
	
	func increment(routeName: String) -> Void {
		callCounts[routeName, default: 0] += 1
    }
}

class RouterTests: XCTestCase {
	let mockPluginManager = MockPluginManager()
	var router: Router!
	
	static let startsWithMessage = Message(body: TextBody(startWithString + "some text after it"), date: Date(), sender: swiftPerson, recipient: mePerson)
	
	static let mePerson = Person(givenName: "zeke", handle: "zeke@email.com", isMe: true)
    static let swiftPerson = Person(givenName: "taylor", handle: "taylor@swift.org", isMe: false)

    override func setUp() {
		router = Router(pluginManager: mockPluginManager, messageDelegates: [])
    }

    override func tearDown() {
    }
	
	func testDisable() {
		// Does contain
		
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
}
