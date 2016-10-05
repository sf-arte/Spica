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
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var flickr : Flickr? = {
        guard let path = Bundle.main.path(forResource: "key", ofType: "txt") else { return nil }
        guard let params = Flickr.OAuthParams(path: path) else { return nil }
        
        return Flickr(params: params)
    }()
    
    /// Flickrから撮ってきた画像のデータ
    private var imageDatas = [URL : Data]()
    
    /// 検索している中心座標
    private var searchingCoordinate = Coordinates()
    
    private var locationManager : CLLocationManager?
    
    /// MARK: メソッド
    
    /// 検索ボタンに対応するメソッド
    @IBAction func search(_ sender: UIBarButtonItem) {
        spinner?.startAnimating()
        let centerCoordinate = mapView.centerCoordinate
        searchingCoordinate = centerCoordinate
        printLog(centerCoordinate)
        
        mapView.removeAnnotations(mapView.annotations)
        flickr?.getPhotos(coordinates: Coordinates(latitude: centerCoordinate.latitude, longitude: centerCoordinate.longitude), radius: 1.0) { [weak self] photos in
            self?.fetchImage(photos: photos){
                for photo in photos {
                    printLog(photo.coordinate)
                }
                if let me = self, me.searchingCoordinate == centerCoordinate {
                    me.mapView.addAnnotations(photos)
                    me.mapView.showAnnotations(me.mapView.annotations, animated: true)
                    me.spinner.stopAnimating()
                }
            }
        }
    }
    
    /// 現在地を表示する
    @IBAction func showCurrentPosition(_ sender: UIBarButtonItem) {
    switch CLLocationManager.authorizationStatus() {
        case .denied, .notDetermined, .restricted:
            locationManager?.requestWhenInUseAuthorization()
            break
        case .authorizedAlways, .authorizedWhenInUse:
            break
        }
        
        if !CLLocationManager.locationServicesEnabled() { return }
        
        locationManager?.requestLocation()
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
        let view = mapView.dequeueReusableAnnotationView(withIdentifier: AnnotationViewReuseIdentifier) ?? MKAnnotationView(annotation: annotation, reuseIdentifier: AnnotationViewReuseIdentifier)
       
        if let photo = annotation as? Photo,
            let url = photo.iconImageURL {
            if let data = imageDatas[url] {
                view.image = UIImage(data: data, scale: 2.0)
            } else {
                printLog("Failed to get an icon image.")
            }
        }
        
        return view
    }
    
    /// PhotoクラスのiconImageURLで指定された画像を取ってくる。
    ///
    /// - parameter photos:     Photoの配列。
    /// - parameter completion: 完了後に行う処理。
    private func fetchImage(photos: [Photo], completion: @escaping () -> ()) {
        imageDatas.removeAll()
        
        let queue = DispatchQueue.global(qos: .userInitiated)
        queue.async {
            for photo in photos {
                if let url = photo.iconImageURL, let iconImageData = try? Data(contentsOf: url) {
                    self.imageDatas[url] = iconImageData
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
        flickr?.authorize()
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        
        if(CLLocationManager.authorizationStatus() == .notDetermined) {
            locationManager?.requestWhenInUseAuthorization()
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
