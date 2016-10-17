//
//  FlickrTests.swift
//  Spica
//
//  Created by Suita Fujino on 2016/10/12.
//  Copyright © 2016年 ARTE Co., Ltd. All rights reserved.
//

import XCTest
@testable import Spica

class FlickrTests: XCTestCase {
    
    var flickr : Flickr = {
        let path = Bundle.main.path(forResource: "key", ofType: "txt")!
        let params = Flickr.OAuthParams(path: path)!
        
        let flickr = Flickr(params: params)
        flickr.authorize()
        return flickr
    }()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testGetPhotosInvalidCoordinate() {
        testGetPhotosShouldFail(coordinates: Coordinates(latitude: 90.01, longitude: 0.0), radius: 5.0, count: 10)
        testGetPhotosShouldFail(coordinates: Coordinates(latitude: 0.0, longitude: 180.01), radius: 5.0, count: 10)
        testGetPhotosShouldFail(coordinates: Coordinates(latitude: -90.01, longitude: 0.0), radius: 5.0, count: 10)
        testGetPhotosShouldFail(coordinates: Coordinates(latitude: 0.0, longitude: -180.01), radius: 5.0, count: 10)
    }
    
    func testGetPhotosValidCoordinate() {
        testGetPhotosShouldSuccess(coordinates: Coordinates(latitude: 35.0, longitude: 135.0), radius: 5.0, count: 10)
        testGetPhotosShouldSuccess(coordinates: Coordinates(latitude: 0.0, longitude: 180.0), radius: 5.0, count: 10)
        testGetPhotosShouldSuccess(coordinates: Coordinates(latitude: 0.0, longitude: -180.0), radius: 5.0, count: 10)
        testGetPhotosShouldSuccess(coordinates: Coordinates(latitude: 90.0, longitude: 0.0), radius: 5.0, count: 10)
        testGetPhotosShouldSuccess(coordinates: Coordinates(latitude: 90.0, longitude: 0.0), radius: 5.0, count: 10)
    }
    
    func testGetPhotoInvalidRadius() {
        testGetPhotosShouldFail(coordinates: Coordinates(latitude: 35.0, longitude: 135.0), radius: -1.0, count: 10)
        testGetPhotosShouldFail(coordinates: Coordinates(latitude: 35.0, longitude: 135.0), radius: 33.0, count: 10)
    }
    
    func testGetPhotoValidRadius() {
        testGetPhotosShouldSuccess(coordinates: Coordinates(latitude: 35.0, longitude: 135.0), radius: 10.0, count: 10)
        testGetPhotosShouldSuccess(coordinates: Coordinates(latitude: 35.0, longitude: 135.0), radius: 32.99, count: 10)
        testGetPhotosShouldSuccess(coordinates: Coordinates(latitude: 35.0, longitude: 135.0), radius: 0.01, count: 10)
    }
    
    func testGetPhotosShouldFail(coordinates: Coordinates, radius: Double, count: Int) {
        let getPhotosExpectation: XCTestExpectation? = self.expectation(description: "getPhotos() failed")
        
        flickr.getPhotos(coordinates: coordinates, radius: radius, count: count){
            photos in
            if(photos.isEmpty) {
                getPhotosExpectation?.fulfill()
            }
        }
        
        waitForExpectations(timeout: 10, handler: nil)
    }
        
    func testGetPhotosShouldSuccess(coordinates: Coordinates, radius: Double, count: Int) {
        let getPhotosExpectation: XCTestExpectation? = self.expectation(description: "getPhotos() succeeded")
        
        flickr.getPhotos(coordinates: coordinates, radius: radius, count: count){
            photos in
            if(!photos.isEmpty) {
                getPhotosExpectation?.fulfill()
            }
        }
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
