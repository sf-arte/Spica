//
//  FlickrTests.swift
//  Spica
//
//  Created by Suita Fujino on 2016/10/12.
//  Copyright © 2016年 ARTE Co., Ltd. All rights reserved.
//

import XCTest
import OAuthSwift
import SwiftyJSON
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
    
    func testAuthorize() {
        let authorizeExpectation = self.expectation(description: "authorize() failed")
        
        class FlickrMock: Flickr {
            let expectation : XCTestExpectation
            
            init(expectation: XCTestExpectation) {
                self.expectation = expectation
                super.init(params: OAuthParams(key: "", secret: ""), loadsToken: false)
            }
            
            override func onAuthorizationFailed(error: OAuthSwiftError) {
                expectation.fulfill()
            }
        }
        
        let flickr = FlickrMock(expectation: authorizeExpectation)
        
        flickr.authorize()
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testGetPhotosWithInvalidCoordinate() {
        testGetPhotosShouldFail(
            leftBottom: Coordinates(latitude: 35.0, longitude: 135.0),
            rightTop:   Coordinates(latitude: 34.0, longitude: 136.0)
        )
        testGetPhotosShouldFail(
            leftBottom: Coordinates(latitude: 35.0, longitude: 135.0),
            rightTop:   Coordinates(latitude: 90.1, longitude: 150.0)
        )
        testGetPhotosShouldFail(
            leftBottom: Coordinates(latitude: 35.0, longitude: -180.1),
            rightTop:   Coordinates(latitude: 36.0, longitude: 136.0)
        )
    }
    
    func testGetPhotosWithValidCoordinate() {
        testGetPhotosShouldSuccess(
            leftBottom: Coordinates(latitude: 35.0, longitude: 135.0),
            rightTop:   Coordinates(latitude: 36.0, longitude: 136.0)
        )
        testGetPhotosShouldSuccess(
            leftBottom: Coordinates(latitude: 0.0, longitude: 0.0),
            rightTop:   Coordinates(latitude: 90.0, longitude: 180.0)
        )
        testGetPhotosShouldSuccess(
            leftBottom: Coordinates(latitude: -90.0, longitude: -180.0),
            rightTop:   Coordinates(latitude: 90.0, longitude: 180.0)
        )
        testGetPhotosShouldSuccess(
            leftBottom: Coordinates(latitude: 35.0, longitude: 175.0),
            rightTop:   Coordinates(latitude: 40.0, longitude: -175.0)
        )
    }
    
    func testGetPhotosOver180thMeridian() {
        testGetPhotosShouldSuccess(
            leftBottom: Coordinates(latitude: 10.0, longitude: 175.0),
            rightTop:   Coordinates(latitude: 80.0, longitude: -175.0)
        )
        testGetPhotosShouldSuccess(
            leftBottom: Coordinates(latitude: 10.0, longitude: 180.0),
            rightTop:   Coordinates(latitude: 80.0, longitude: -160.0)
        )
    }
    
    func testDecode() {
        let elements : [String : Any] = [
            "id": "1111111111",
            "owner": "222222222@N22",
            "secret": "1a2b3c4d5",
            "server": "1234",
            "farm": 1,
            "title": "東京",
            "ownername": "hoge",
            "latitude": 35.681382,
            "longitude": 139.766084,
            "url_o": "https://farm6.staticflickr.com/5819/30423578985_bb26300a4c_o.jpg",
            "url_sq": "https://farm6.staticflickr.com/5819/30423578985_bb26300a4c_s.jpg",
            "url_l" : "https://farm6.staticflickr.com/5819/30423578985_bb26300a4c_z_d.jpg"
        ]
        
        let json = JSON(elements)
        
        let photo = Flickr.decode(from: json)
        
        XCTAssertEqual(photo.id, 1111111111)
        XCTAssertEqual(photo.owner, "222222222@N22")
        XCTAssertEqual(photo.title, "東京")
        XCTAssertEqual(photo.ownerName, "hoge")
        XCTAssertEqual(photo.coordinate.latitude, 35.681382)
        XCTAssertEqual(photo.coordinate.longitude, 139.766084)
        XCTAssertEqual(photo.urls.originalImageURL, URL(string: "https://farm6.staticflickr.com/5819/30423578985_bb26300a4c_o.jpg"))
        XCTAssertEqual(photo.urls.iconImageURL, URL(string: "https://farm6.staticflickr.com/5819/30423578985_bb26300a4c_s.jpg"))
        XCTAssertEqual(photo.urls.largeImageURL, URL(string: "https://farm6.staticflickr.com/5819/30423578985_bb26300a4c_z_d.jpg"))
    }

    func testGetPhotosShouldFail(leftBottom: Coordinates, rightTop: Coordinates) {
        let getPhotosExpectation = self.expectation(description: "getPhotos() failed")
        
        flickr.getPhotos(leftBottom: leftBottom, rightTop: rightTop, count: 10, text: nil){
            photos in
            if(photos.isEmpty) {
                getPhotosExpectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 10, handler: nil)
    }
        
    func testGetPhotosShouldSuccess(leftBottom: Coordinates, rightTop: Coordinates) {
        let getPhotosExpectation = self.expectation(description: "getPhotos() succeeded")
        
        flickr.getPhotos(leftBottom: leftBottom, rightTop: rightTop, count: 10, text: nil){
            photos in
            if(!photos.isEmpty) {
                getPhotosExpectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
}
