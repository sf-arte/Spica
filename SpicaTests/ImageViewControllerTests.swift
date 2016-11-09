//
//  ImageViewControllerTests.swift
//  Spica
//
//  Created by Suita Fujino on 2016/11/09.
//  Copyright © 2016年 ARTE Co., Ltd. All rights reserved.
//

import XCTest
@testable import Spica

class ImageViewControllerTests: XCTestCase {
    
    var imageViewContoller : ImageViewController?
    
    override func setUp() {
        super.setUp()
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let mapViewController = storyboard.instantiateInitialViewController() as? MapViewController else {
            fatalError()
        }
        
        UIApplication.shared.keyWindow?.rootViewController = mapViewController
        
        let _ = mapViewController.view
        
        var photos: [Photo] = []
        
        for i in 1...10 {
            let photo = Photo(
                id: 1,
                owner: "hoge\(i)",
                ownerName: "hoge",
                iconURL: "hoge",
                largeURL: "hoge",
                originalURL: "https://farm6.staticflickr.com/5819/30423578985_bb26300a4c_z_d.jpg",
                photoTitle: "hoge\(i)",
                coordinate: Coordinates(latitude: 35.0, longitude: 135.0)
            )
            
            photos.append(photo)
        }
        
        mapViewController.mapView.addAnnotations(photos)
        
        mapViewController.mapView.selectAnnotation(mapViewController.mapView.annotations[3], animated: false)
        
        imageViewContoller = UIApplication.shared.keyWindow?.rootViewController?.presentedViewController as? ImageViewController
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testRecognizeSwipe() {
        let recognizer = UISwipeGestureRecognizer()
        recognizer.direction = .right
        
        let text = imageViewContoller?.titleLabel.text
        
        imageViewContoller?.recognizeSwipe(recognizer)
        
        XCTAssertNotEqual(imageViewContoller?.titleLabel.text, text)
    }
}
