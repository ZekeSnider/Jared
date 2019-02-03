//
//  MessageTests.swift
//  JaredTests
//
//  Created by Zeke Snider on 2/3/19.
//  Copyright © 2019 Zeke Snider. All rights reserved.
//

import XCTest
import JaredFramework




class MessageTests: XCTestCase {
    let textBody = TextBody("Hey Jared")
    
    let jaredPerson = Person(givenName: "jared", handle: "jared@email.com", isMe: false, inGroup: nil)
    let mePerson = Person(givenName: "zeke", handle: "zeke@email.com", isMe: true, inGroup: nil)
    let swiftPerson = Person(givenName: "taylor", handle: "taylor@swift.org", isMe: false, inGroup: nil)
    
    var sampleGroup: Group!
    
    var sampleTextMessage: Message!
    var sampleImageMesage: Message!
    var messageFromMeToGroup: Message!
    var messageFromMeToPerson: Message!
    var messageFromPersonToGroup: Message!
    
    override func setUp() {
        sampleGroup = Group(name: "thank u next", handle: "chat1000", participants: [mePerson, jaredPerson, swiftPerson])
        
        sampleTextMessage = Message(body: textBody, date: Date(), sender: mePerson, recipient: jaredPerson)
        sampleImageMesage = Message(body: ImageBody("/users/zeke/goodJaredImage.jpg"), date: Date(), sender: mePerson, recipient: jaredPerson)
        
        messageFromMeToGroup = Message(body: textBody, date: Date(), sender: mePerson, recipient: sampleGroup)
        messageFromPersonToGroup = Message(body: textBody, date: Date(), sender: swiftPerson, recipient: sampleGroup)
        messageFromMeToPerson = Message(body: textBody, date: Date(), sender: mePerson, recipient: swiftPerson)
    }

    override func tearDown() {
    }

    func testGetTextBody() {
        XCTAssert(sampleTextMessage.getTextBody() == "Hey Jared", "getTextBody returns proper string")
        XCTAssert(sampleImageMesage.getTextBody() == nil, "getTextBody returns nil for image body")
    }
    
    func testGetImageBody() {
        XCTAssert(sampleTextMessage.getImageBody() == nil, "getTextBody returns nil for text body")
        XCTAssert(sampleImageMesage.getImageBody() == "/users/zeke/goodJaredImage.jpg", "getTextBody returns proper path")
    }
    
    func testGetMessageResponse() {
        XCTAssert(sampleTextMessage.RespondTo() as? Person == jaredPerson, "Message from me to person responds to recipient")
        XCTAssert(messageFromMeToGroup.RespondTo() as? Group == sampleGroup, "Message from me to group responds to group")
        XCTAssert(messageFromPersonToGroup.RespondTo() as? Group == sampleGroup, "Message from person to group responds to group")
        XCTAssert(messageFromMeToPerson.RespondTo() as? Person == swiftPerson, "Message from me to person responds to person")
    }
}
