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
    
    /// MARK: 定数
    private let AnnotationViewReuseIdentifier = "photo"
    
    /// MARK: プロパティ
    
    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            mapView.delegate = self
        }
    }
    
    var flickr : Flickr? = {
        if let path = Bundle.main.path(forResource: "key", ofType: "txt") {
            return Flickr(path: path)
        }
        return nil
    }()
    
    /// MARK: メソッド
    
    /// 検索ボタンに対応するメソッド
    @IBAction func search(_ sender: UIButton) {
        let centerCoordinate = mapView.centerCoordinate
        
        mapView.removeAnnotations(mapView.annotations)
        flickr?.getPhotos(coordinates: Coordinates(latitude: centerCoordinate.latitude, longitude: centerCoordinate.longitude), accuracy: 10) { photos in
            for photo in photos {
               self.mapView.addAnnotation(photo)
            }
        }
        mapView.showAnnotations(mapView.annotations, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let view = mapView.dequeueReusableAnnotationView(withIdentifier: AnnotationViewReuseIdentifier) ?? MKAnnotationView(annotation: annotation, reuseIdentifier: AnnotationViewReuseIdentifier)
       
        guard let photo = annotation as? Photo else { fatalError() }
        if let url = photo.iconImageURL, let iconImageData = try? Data(contentsOf: url) {
            view.image = UIImage(data: iconImageData)
        } else {
            printLog("Couldn't show icon image.")
        }
        
        return view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        flickr?.authorize()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
