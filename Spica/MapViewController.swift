//
//  MapViewController.swift
//  Spica
//
//  Created by Suita Fujino on 2016/09/27.
//  Copyright © 2016年 ARTE Co., Ltd. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            mapView.delegate = self
        }
    }
    
    @IBAction func search(_ sender: UIButton) {
        fl.getPhotos(coordinates: Flickr.Coordinates(latitude: 35.0, longitude: 135.0), accuracy: 10)
    }
    
    var fl = Flickr()

    override func viewDidLoad() {
        super.viewDidLoad()
        fl.authorize()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
