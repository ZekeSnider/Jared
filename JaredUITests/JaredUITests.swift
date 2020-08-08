//
//  JaredUITests.swift
//  JaredUITests
//
//  Created by Zeke Snider on 8/7/20.
//  Copyright © 2020 Zeke Snider. All rights reserved.
//

import XCTest

class JaredUITests: XCTestCase {
    override func setUpWithError() throws {
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        print(Bundle.main.bundleIdentifier!)
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.standard.synchronize()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launchArguments.append("-UITesting")
        app.launch()
        
        let jaredWindow = XCUIApplication().windows["Jared"]
        let disabledText = jaredWindow.staticTexts["Jared is currently disabled"]
        let disabledImage = jaredWindow.images["unavailable"]
        
        let enabledImage = jaredWindow.children(matching: .image).matching(identifier: "available").element(boundBy: 0)
        let enabledText = jaredWindow.staticTexts["Jared is currently enabled"]
        
        let disableButton = jaredWindow.buttons["Disable Jared"]
        let enableButton = jaredWindow.buttons["Enable Jared"]
        
        jaredWindow.click()
        XCTAssertFalse(disabledText.exists)
        XCTAssertFalse(disabledImage.exists)
        XCTAssertTrue(enabledText.exists)
        XCTAssertTrue(enabledImage.exists)
        XCTAssertFalse(enableButton.exists)
        
        disableButton.click()
        
        XCTAssertTrue(disabledText.exists)
        XCTAssertTrue(disabledImage.exists)
        XCTAssertFalse(enabledText.exists)
        XCTAssertTrue(enableButton.exists)
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTOSSignpostMetric.applicationLaunch]) {
                XCUIApplication().launch()
            }
        }
    }
}
