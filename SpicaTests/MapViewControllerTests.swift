//
//  MapViewControllerTests.swift
//  Spica
//
//  Created by Suita Fujino on 2016/11/14.
//  Copyright © 2016年 ARTE Co., Ltd. All rights reserved.
//

import XCTest
import SwiftyJSON
@testable import Spica

class MapViewControllerTests: XCTestCase {
    
    class FlickrMock : Flickr {
        init() {
            super.init(params: Flickr.OAuthParams(key: "hoge", secret: "hoge"), loadsToken: false)
        }
        
        override func getPhotos(leftBottom: Coordinates, rightTop: Coordinates, count: Int, text: String?, handler: @escaping ([Photo]) -> ()) {
            var photos: [Photo] = []
            
            for i in 1...3 {
                let photo = Photo(
                    id: 1,
                    owner: "222222222@N22",
                    ownerName: "hoge",
                    iconURL: "https://farm6.staticflickr.com/5819/30423578985_bb26300a4c_s.jpg",
                    largeURL: "hoge",
                    originalURL: "https://farm6.staticflickr.com/5819/30423578985_bb26300a4c_z_d.jpg",
                    photoTitle: "hoge\(i)",
                    coordinate: Coordinates(latitude: 35.6813, longitude: 139.7660 + Double(i) * 0.01)
                )
                
                photos.append(photo)
            }
            
            handler(photos)
        }
    }
    
    var mapViewController: MapViewController?
    
    override func setUp() {
        super.setUp()
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        mapViewController = storyboard.instantiateInitialViewController() as? MapViewController
        
        UIApplication.shared.keyWindow?.rootViewController = mapViewController
        
        let _ = mapViewController?.view
        
        mapViewController?.flickr = FlickrMock()

    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testGetPhotos() {
        XCTAssertNotNil(mapViewController)
        guard let mapViewController = mapViewController else { fatalError() }
        
        let expectation = self.expectation(description: "getPhotos() completed.")
        
        mapViewController.getPhotos(text: nil) {
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 20, handler: nil)
        
        XCTAssert(mapViewController.mapView.annotations.count > 1)
    }
    
    func testDrawRoute() {
        XCTAssertNotNil(mapViewController?.mapView)
        guard let mapView = mapViewController?.mapView else { fatalError() }
        
        let photos = [
            Photo(
                id: 1,
                owner: "hoge",
                ownerName: "hoge",
                iconURL: "hoge",
                largeURL: "hoge",
                originalURL: "hoge",
                photoTitle: "hoge",
                coordinate: Coordinates(latitude: 35.0, longitude: 135.0)
            ),
            Photo(
                id: 1,
                owner: "hoge",
                ownerName: "hoge",
                iconURL: "hoge",
                largeURL: "hoge",
                originalURL: "hoge",
                photoTitle: "hoge",
                coordinate: Coordinates(latitude: 35.1, longitude: 135.1)
            )
        ]
        
        mapView.addAnnotations(photos)
        
        let expectation = self.expectation(description: "drawRoute() completed.")
        
        mapViewController?.drawRoute(from: mapView.annotations[0], to: mapView.annotations[1], animated: true) {
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 10, handler: nil)
        
        XCTAssertFalse(mapView.overlays.isEmpty)
    }
 
}
