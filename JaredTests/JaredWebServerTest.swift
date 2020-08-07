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
    static let invalidBody = "{dskjfal/iqwkjfdslol}"
    
    var jaredMock: JaredMock!
    var testDatabaseLocation: URL!
    var webServer: JaredWebServer!
    
    override func setUp() {
        jaredMock = JaredMock()
        let bundle = Bundle(for: type(of: self))
        testDatabaseLocation = bundle.url(forResource: "config", withExtension: "json")
        webServer = JaredWebServer(sender: jaredMock, configurationURL: testDatabaseLocation)
    }
    
    override func tearDown() {
    }
    
    func testInvalidRequest() {
        // Start the server
        webServer.start()
        
        // Make an invalid post request
        var request = URLRequest(url: URL(string: "http://localhost:3000/message")!)
        request.httpMethod = "POST"
        request.httpBody = JaredWebServerTest.invalidBody.data(using: String.Encoding.utf8)
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        var httpResponse: HTTPURLResponse?
        let semaphore = DispatchSemaphore(value: 0)
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            httpResponse = response as? HTTPURLResponse
            semaphore.signal()
        }.resume()
        
        _ = semaphore.wait(timeout: .distantFuture)
        XCTAssertEqual(httpResponse?.statusCode, 400, "Bad request status header")
        
        // Stop the server
        webServer.stop()
        
        // Make a request and verify that it doesn't work
        var requestError: Error?
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            requestError = error
            semaphore.signal()
        }.resume()
        _ = semaphore.wait(timeout: .distantFuture)
        print()
        XCTAssertEqual(requestError?.localizedDescription, "Could not connect to the server.", "Request fails when the server is stopped")
    }
}
