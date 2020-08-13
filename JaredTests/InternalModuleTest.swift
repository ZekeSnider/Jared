//
//  InternalModuleTest.swift
//  JaredTests
//
//  Created by Zeke Snider on 8/6/20.
//  Copyright © 2020 Zeke Snider. All rights reserved.
//

import XCTest
import JaredFramework

class InternalModuleTest: XCTestCase {
    var internalModule: InternalModule!
    var sender: JaredMock!
    var pluginManager: MockPluginManager!
    let mePerson = Person(givenName: "zeke", handle: "zeke@email.com", isMe: true)
    let swiftPerson = Person(givenName: "taylor", handle: "taylor@swift.org", isMe: false)
    
    override func setUp() {
        self.sender = JaredMock()
        self.pluginManager = MockPluginManager()
        internalModule = InternalModule(sender: sender, pluginManager: pluginManager)
    }

    override func tearDown() {
    }

    func testExample() throws {
        let module1 = MockRoute(sender: JaredMock())
        module1.add(route: Route(name: startWithString, comparisons: [.startsWith: [startWithString]], call: {(message: Message) -> Void in self.pluginManager.increment(routeName: startWithString)}, description: "hello hello", parameterSyntax: "example syntax"))
        module1.add(route: Route(name: containsString, comparisons: [.contains: [containsString]], call: {(message) -> Void in self.pluginManager.increment(routeName: containsString)}, description: "sfadjklfsa"))
        module1.add(route: Route(name: containsString, comparisons: [.containsURL: [goodUrl]], call: {(message) -> Void in self.pluginManager.increment(routeName: containsString)}))
        module1.add(route: Route(name: isString, comparisons: [.is: [isString]], call: {(message) -> Void in self.pluginManager.increment(routeName: isString)}))
        
        pluginManager.add(module: module1)
        
        internalModule.sendDocumentation(Message(body: TextBody(""), date: Date(), sender: mePerson, recipient: swiftPerson))
        var message = (sender.calls[0].body as! TextBody).message
        XCTAssertEqual(message, "MockRoute: no description\n==============\n/startWith: hello hello\n/contains: sfadjklfsa\n/contains: \n/is: ")
        
        internalModule.sendDocumentation(Message(body: TextBody("/help,\(startWithString)"), date: Date(), sender: mePerson, recipient: swiftPerson))
        message = (sender.calls[1].body as! TextBody).message
        XCTAssertEqual(message, "Command: /startWith\n===========\nhello hello\n\nParameters: example syntax")
    }

}
