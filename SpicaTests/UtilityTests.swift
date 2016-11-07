//
//  UtilityTests.swift
//  Spica
//
//  Created by Suita Fujino on 2016/11/07.
//  Copyright © 2016年 ARTE Co., Ltd. All rights reserved.
//

import XCTest

class UtilityTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testTimeIntervalToString() {
        XCTAssertEqual(TimeInterval(0.0).string, "0分")
        XCTAssertEqual(TimeInterval(2400.0).string, "40分")
        XCTAssertEqual(TimeInterval(3599.99).string, "59分")
        XCTAssertEqual(TimeInterval(3600.0).string, "1時間0分")
        XCTAssertEqual(TimeInterval(9030.0).string, "2時間30分")
        XCTAssertEqual(TimeInterval(86399.99).string, "23時間59分")
        XCTAssertEqual(TimeInterval(86400.0).string, "1日0時間")
        XCTAssertEqual(TimeInterval(100000.0).string, "1日3時間")
        XCTAssertEqual(TimeInterval(1000000.0).string, "11日13時間")
    }
    
    
}
