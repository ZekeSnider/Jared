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
        
        let timestamp2 = currentTimestamp()
        let messageID2 = helper.insertMessage(guid: "lol2", messageText: "hello world", handleID: handleID, service: "iMessage", account: "zeke", accountGuid: "String", date: timestamp2, dateRead: nil, dateDelivered: nil, isFromMe: true, hasAttachments: true, destinationCallerID: "zeke")
        helper.linkChatAndMessage(chatID: chatID, messageID: messageID2, date: timestamp2)
        let attachmentID = helper.insertAttachment(guid: "qq", createdAt: timestamp2, filePath: "~/fdsf", mimeType: "image/jpeg", isOutgoing: true, transferName: "hello.jpg", isSticker: false)
        helper.linkAttachmentAndMessage(messageID: messageID2, attachmentID: attachmentID)
        
        sleep(10)
        
        XCTAssertEqual(router.messages.count, 2, "Both messages routed")
    }
}
