//
//  MapViewController.swift
//  Spica
//
//  Created by Suita Fujino on 2016/09/27.
//  Copyright © 2016年 ARTE Co., Ltd. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    /// MARK: 定数
    private let AnnotationViewReuseIdentifier = "photo"
    
    /// MARK: プロパティ
    
    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            mapView.delegate = self
        }
    }
    
    @IBOutlet weak var currentPositionButton: UIBarButtonItem!
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var flickr : Flickr? = {
        guard let path = Bundle.main.path(forResource: "key", ofType: "txt") else { return nil }
        guard let params = Flickr.OAuthParams(path: path) else { return nil }
        
        let flickr = Flickr(params: params)
        flickr.authorize()
        return flickr
    }()
    
    /// 検索している中心座標
    private var searchingCoordinate = Coordinates()
    
    private let locationManager = CLLocationManager()
    
    /// MARK: メソッド
    
    /// 検索ボタンに対応するメソッド
    @IBAction func search(_ sender: UIBarButtonItem) {
        spinner?.startAnimating()
        let centerCoordinate = mapView.centerCoordinate
        searchingCoordinate = centerCoordinate
        printLog(centerCoordinate)
        
        mapView.removeAnnotations(mapView.annotations)
        flickr?.getPhotos(coordinates: centerCoordinate, radius: 1.0) { [weak self] photos in
            self?.fetchImages(photos: photos){
                for photo in photos {
                    printLog(photo.coordinate)
                }
                if let strongSelf = self, strongSelf.searchingCoordinate == centerCoordinate {
                    strongSelf.mapView.addAnnotations(photos)
                    strongSelf.mapView.showAnnotations(strongSelf.mapView.annotations, animated: true)
                    strongSelf.spinner.stopAnimating()
                }
            }
        }
    }
    
    /// 現在地を表示する
    @IBAction func showCurrentPosition(_ sender: UIBarButtonItem) {
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestLocation()
        }
    }

    /// 位置情報の更新に成功した時呼ばれる
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = manager.location {
            mapView.setCenter(location.coordinate, animated: true)
        }
    }
    
    /// 位置情報の更新に失敗した時呼ばれる
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        printLog(error)
    }
    
    /// MKAnnotationViewをカスタムする
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // 現在地のアイコン
        if annotation is MKUserLocation {
            return nil
        }
        
        // サムネイルを表示するカスタムビュー
        let view = mapView.dequeueReusableAnnotationView(withIdentifier: AnnotationViewReuseIdentifier) ?? MKAnnotationView(annotation: annotation, reuseIdentifier: AnnotationViewReuseIdentifier)
        view.canShowCallout = true
        
        
        if let photo = annotation as? Photo,
            let image = photo.iconImage {
            view.image = image
        }
        
        return view
    }
    
    /// PhotoクラスのiconImageURLで指定された画像を取ってくる。
    ///
    /// - parameter photos:     Photoの配列。
    /// - parameter completion: 完了後に行う処理。
    private func fetchImages(photos: [Photo], completion: @escaping () -> ()) {
        let queue = DispatchQueue.global(qos: .userInitiated)
        queue.async {
            for photo in photos {
                if let url = photo.urls.iconImageURL, let iconImageData = try? Data(contentsOf: url) {
                    photo.iconImage = UIImage(data: iconImageData, scale: 2.0)
                } else {
                    printLog("Couldn't fetch an icon image.")
                }
            }
            
            DispatchQueue.main.async {
                completion()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        
        
        // とりあえず現在地を表示
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestLocation()
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
