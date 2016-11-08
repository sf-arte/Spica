//
//  SpicaUITests.swift
//  SpicaUITests
//
//  Created by Suita Fujino on 2016/11/01.
//  Copyright © 2016年 ARTE Co., Ltd. All rights reserved.
//

import XCTest

class SpicaUITests: XCTestCase {
        
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
    
    func testTextSearch() {
        let app = XCUIApplication()
        
        let predicate = NSPredicate(format: "label CONTAINS '東京'")
        
        XCTAssert(!app.otherElements.element(matching: predicate).exists)
        
        search()
        
        XCTAssert(app.otherElements.element(matching: predicate).exists)
    }
    
    func testRouteFinding() {
        let app = XCUIApplication()
        
        search()
        
        let annotations = app.otherElements.matching(NSPredicate(format: "label CONTAINS '東京'"))
        annotations.element(boundBy: 1).tap()
        
        app.buttons["Route Button"].tap()
        
        let predicate = NSPredicate(format: "label != ' '")
        expectation(for: predicate, evaluatedWith: app.staticTexts.element, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testImageView() {
        let app = XCUIApplication()
        
        search()
        
        let annotations = app.otherElements.matching(NSPredicate(format: "label CONTAINS '東京'"))
        annotations.element(boundBy: 1).tap()
        
        let element = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element
        element.swipeRight()
        element.swipeLeft()
        app.buttons["×"].tap()
        
        XCTAssert(app.otherElements.element(matching: NSPredicate(format: "label CONTAINS '東京'")).exists)
    }
    
    func search() {
        let app = XCUIApplication()
       
        let searchField = app.searchFields.element
        searchField.tap()
        searchField.typeText("東京駅")
        app.keyboards.buttons["Search"].tap()
        
        let notExists = NSPredicate(format: "exists == false")
        expectation(for: notExists, evaluatedWith: app.activityIndicators.element, handler: nil)
        waitForExpectations(timeout: 30, handler: nil)
    }
    
}
