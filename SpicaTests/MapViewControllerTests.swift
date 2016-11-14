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
    
 
}
