//
//  SpicaUITests.swift
//  SpicaUITests
//
//  Created by Suita Fujino on 2016/11/01.
//  Copyright © 2016年 ARTE Co., Ltd. All rights reserved.
//

import XCTest

class SpicaUITests: XCTestCase {
    
    let photoAccessibilityIdentifier = "Photo"
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        let app = XCUIApplication()
        app.launchArguments = ["--mockserver"]
        app.launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSearch() {
        let app = XCUIApplication()
        
        XCTAssert(!app.otherElements[photoAccessibilityIdentifier].exists)
        
        search()
        
        XCTAssert(app.otherElements[photoAccessibilityIdentifier].exists)
    }
    
    func testRouteFinding() {
        let app = XCUIApplication()
        
        search()
        
        XCTAssert(app.otherElements[photoAccessibilityIdentifier].exists)
        let annotations = app.otherElements.matching(identifier: photoAccessibilityIdentifier)
        annotations.element(boundBy: 1).tap()
        
        app.buttons["Route Button"].tap()
        
        let predicate = NSPredicate(format: "label != ' '")
        expectation(for: predicate, evaluatedWith: app.staticTexts.element, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testImageView() {
        let app = XCUIApplication()
        
        search()
        
        XCTAssert(app.otherElements[photoAccessibilityIdentifier].exists)
        let annotations = app.otherElements.matching(identifier: photoAccessibilityIdentifier)
        annotations.element(boundBy: 1).tap()
        
        let title = app.staticTexts["Title Label"].label
        let element = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element
        
        element.swipeRight()
        XCTAssertNotEqual(title, app.staticTexts["Title Label"].label)
        element.swipeLeft()
        XCTAssertEqual(title, app.staticTexts["Title Label"].label)
        app.buttons["×"].tap()
        
        XCTAssert(app.otherElements[photoAccessibilityIdentifier].exists)
    }
    
    func search() {
        let app = XCUIApplication()
       
        app.toolbars.buttons["Search"].tap()
        
        let notExists = NSPredicate(format: "exists == false")
        expectation(for: notExists, evaluatedWith: app.activityIndicators.element, handler: nil)
        waitForExpectations(timeout: 30, handler: nil)
    }
    
}
