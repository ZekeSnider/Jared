//
//  MessageTests.swift
//  JaredTests
//
//  Created by Zeke Snider on 2/3/19.
//  Copyright © 2019 Zeke Snider. All rights reserved.
//

import XCTest
import JaredFramework

class DatabaseHandlerTest: XCTestCase {
    var testDatabaseLocation: URL! = nil
    var helper: DatabaseTestHelper! = nil
    var router: MockRouter! = nil
    var databaseHandler: DatabaseHandler! = nil
    
    private func currentTimestamp() -> Int {
        return Int(Date().timeIntervalSinceReferenceDate * 1000000000)
    }
    
    override func setUp() {
        let bundle = Bundle(for: type(of: self))
        testDatabaseLocation = bundle.url(forResource: "scaffold", withExtension: "db")
        helper = DatabaseTestHelper(databaseLocation: testDatabaseLocation)
        router = MockRouter()
        databaseHandler = DatabaseHandler(router: router, databaseLocation: testDatabaseLocation, diskAccessDelegate: nil)
        databaseHandler.start()
    }
    
    override func tearDown() {
    }
    
    
    func testHandle() {
        let handleID = helper.insertHandle(id: "zeke", service: "iMessage")
        let chatID = helper.insertChat(accountId: "zeke", service: "iMessage")
        helper.linkChatAndHandle(chatID: chatID, handleID: handleID)
        
        let timestamp = currentTimestamp()
        let messageID = helper.insertMessage(guid: "lol", messageText: "hello world", handleID: handleID, service: "iMessage", account: "zeke", accountGuid: "String", date: timestamp, dateRead: nil, dateDelivered: nil, isFromMe: true, hasAttachments: false, destinationCallerID: "zeke")
        helper.linkChatAndMessage(chatID: chatID, messageID: messageID, date: timestamp)
        
        sleep(10)
        
        XCTAssertEqual(router.messages.count, 1, "count is 1")
    }
}
