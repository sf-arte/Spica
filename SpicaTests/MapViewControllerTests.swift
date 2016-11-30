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
            guard let url = URL(string: "http://127.0.0.1:4567/rest/") else { return }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let data = data {
                    let json = JSON(data: data)
                    
                    handler(json["photos"]["photo"].arrayValue.map{ Flickr.decode(from: $0) })
                }
            }.resume()
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
