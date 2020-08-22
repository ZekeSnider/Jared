//
//  MessageTests.swift
//  JaredTests
//
//  Created by Zeke Snider on 2/3/19.
//  Copyright © 2019 Zeke Snider. All rights reserved.
//

import XCTest
import JaredFramework

class JaredWebServerTest: XCTestCase {
    static let validBody = "{\"body\": {\"message\": \"clandestine meetings\"},\"recipient\": {\"handle\": \"handle@email.com\"}}"
    static let invalidBody = "{dskjfal/iqwkjfdslol}"
    
    var jaredMock: JaredMock!
    var testDatabaseLocation: URL!
    var webServer: JaredWebServer!
    
    override func setUp() {
        jaredMock = JaredMock()
        let configuration = WebserverConfiguration(port: 3005)
        webServer = JaredWebServer(sender: jaredMock, configuration: configuration)
    }
    
    override func tearDown() {
    }
    
    func testInvalidRequest() {
        // Start the server
        webServer.start()
        
        // Make an invalid post request
        var request = URLRequest(url: URL(string: "http://localhost:3005/message")!)
        request.httpMethod = "POST"
        request.httpBody = JaredWebServerTest.invalidBody.data(using: String.Encoding.utf8)
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        var httpResponse: HTTPURLResponse?
        let badRequestPromise = XCTestExpectation(description: "bad request response received")
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            httpResponse = response as? HTTPURLResponse
            badRequestPromise.fulfill()
        }.resume()
        
        wait(for: [badRequestPromise], timeout: 5)
        XCTAssertEqual(httpResponse?.statusCode, 400, "Bad request status header")
        
        // Stop the server
        webServer.stop()
        
        // Make a request and verify that it doesn't work
        var requestError: Error?
        let noResponsePromise = XCTestExpectation(description: "no response received")
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            requestError = error
            noResponsePromise.fulfill()
        }.resume()
        wait(for: [noResponsePromise], timeout: 5)
        print()
        XCTAssertEqual(requestError?.localizedDescription, "Could not connect to the server.", "Request fails when the server is stopped")
    }
    
    func testValidRequest() {
        // Start the server
        webServer.start()
        
        // Make an invalid post request
        var request = URLRequest(url: URL(string: "http://localhost:3005/message")!)
        request.httpMethod = "POST"
        request.httpBody = JaredWebServerTest.validBody.data(using: String.Encoding.utf8)
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        var httpResponse: HTTPURLResponse?
        let promise = XCTestExpectation(description: "response received")
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            httpResponse = response as? HTTPURLResponse
            promise.fulfill()
        }.resume()
        
        wait(for: [promise], timeout: 5)
        XCTAssertEqual(httpResponse?.statusCode, 200, "Valid request is successful")
        XCTAssertEqual(jaredMock.calls.count, 1, "One message sent")
        XCTAssertEqual((jaredMock.calls[0].body as! TextBody).message, "clandestine meetings", "Message was correct")
        XCTAssertEqual((jaredMock.calls[0].recipient as! AbstractRecipient).handle, "handle@email.com", "recipient email is correct")
    }
}
