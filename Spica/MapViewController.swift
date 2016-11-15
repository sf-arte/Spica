//
//  MapViewController.swift
//  Spica
//
//  Created by Suita Fujino on 2016/09/27.
//  Copyright © 2016年 ARTE Co., Ltd. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate {
    
    // MARK: 定数
    
    private let AnnotationViewReuseIdentifier = "photo"
    private let ShowImageSegueIdentifier = "Show Image"
    
    // MARK: - プロパティ
    
    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            mapView.delegate = self
        }
    }
    
    @IBOutlet weak var searchBar: UISearchBar! {
        didSet {
            searchBar.delegate = self
        }
    }
    
    @IBOutlet weak var currentLocationButton: UIBarButtonItem!
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    @IBOutlet weak var routeDurationLabel: UILabel! {
        didSet {
            routeDurationLabel.accessibilityIdentifier = "Route Label"
        }
    }
    
    var flickr : Flickr? = {
        guard let path = Bundle.main.path(forResource: "key", ofType: "txt") else { return nil }
        guard let params = Flickr.OAuthParams(path: path) else { return nil }
        
        let flickr = Flickr(params: params)
        flickr.authorize()
        return flickr
    }()
    
    /// マルチスレッドでannotationsを追加する際の照合用
    private var searchingCoordinate = Coordinates()
    
    private let locationManager = CLLocationManager()
    
    // MARK: - メソッド
    
    /// 検索ボタンに対応するメソッド
    @IBAction func search(_ sender: UIBarButtonItem) {
        getPhotos(text: searchBar.text)
    }
    
    /// 現在地ボタンに対応するメソッド
    @IBAction func showCurrentLocation(_ sender: UIBarButtonItem) {
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestLocation()
        }
    }
    
    @IBAction func unwind(segue: UIStoryboardSegue) {
        if let ivc = segue.source as? ImageViewController, let photo = ivc.photo {
            mapView.selectAnnotation(photo, animated: true)
        }
    }
    
    @IBAction func unwindAndDrawRoute(segue: UIStoryboardSegue) {
        if let ivc = segue.source as? ImageViewController, let photo = ivc.photo {
            mapView.selectAnnotation(photo, animated: true)
            
            drawRoute(from: mapView.userLocation, to: photo, animated: true)
        }
    }

    
    // 長押しを検知した時経路検索をする
    @IBAction func recognizeLongPress(_ sender: UILongPressGestureRecognizer) {
//        if sender.state != .began {
//            return
//        }
//        
//        let location = sender.location(in: mapView)
//        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
//        
//        drawRoute(from: mapView.userLocation.coordinate, to: coordinate)
        
    }
    

    /// 位置情報の更新に成功した時呼ばれる
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = manager.location {
            mapView.setCenter(location.coordinate, animated: true)
        }
    }
    
    /// 位置情報の更新に失敗した時呼ばれる
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        log?.error(error)
    }
    
    /// MKAnnotationViewをカスタムする
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // 現在地のアイコン
        if annotation is MKUserLocation {
            return nil
        }
        
        // サムネイルを表示するカスタムビュー
        let view = mapView.dequeueReusableAnnotationView(withIdentifier: AnnotationViewReuseIdentifier) ?? MKAnnotationView(annotation: annotation, reuseIdentifier: AnnotationViewReuseIdentifier)
        
        if let photo = annotation as? Photo,
            let image = photo.iconImage {
            view.image = image
            // 見た目の調整
            view.layer.borderColor = UIColor.white.cgColor
            view.layer.borderWidth = 1
        }
        
        return view
    }
    
    /// Annotationが選択された時の処理
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let photo = view.annotation as? Photo {
            view.layer.borderColor = UIColor(displayP3Red: 0.0, green: 0.6, blue: 1.0, alpha: 1.0).cgColor
            view.layer.borderWidth = 2
            
            if view.window != nil && (photo.urls.originalImageURL != nil || photo.urls.largeImageURL != nil) {
                performSegue(withIdentifier: ShowImageSegueIdentifier, sender: view)
            }
        }
    }
    
    /// Annotationの選択が外れた時の処理
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if view.annotation is Photo {
            view.layer.borderColor = UIColor.white.cgColor
            view.layer.borderWidth = 1
        }
    }
    
    /// overlayの描画処理
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.lineWidth = 2.0
        renderer.strokeColor = UIColor.blue
        
        return renderer
    }
    
    /// 検索バーのキーボードで検索ボタンが押された時の処理
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        getPhotos(text: searchBar.text)
        
        searchBar.resignFirstResponder()
    }
    
    /// Flickr.getPhotos()を呼び、サムネイル画像を地図上にプロットする
    /// 
    /// - parameter text: 検索する文字列
    /// - parameter completion: 完了時の処理
    func getPhotos(text: String? = nil, completion: (() -> ())? = nil) {
        spinner?.startAnimating()
        let centerCoordinate = mapView.centerCoordinate
        searchingCoordinate = centerCoordinate
        
        let rect = mapView.visibleMapRect
        let leftBottom = MKMapPointMake(MKMapRectGetMinX(rect), MKMapRectGetMaxY(rect))
        let rightTop = MKMapPointMake(MKMapRectGetMaxX(rect), MKMapRectGetMinY(rect))
        
        let leftBottomCoordinate = MKCoordinateForMapPoint(leftBottom)
        let rightTopCoordinate = MKCoordinateForMapPoint(rightTop)
        
        clearRoute()
        mapView.removeAnnotations(mapView.annotations)
        
        flickr?.getPhotos(leftBottom: leftBottomCoordinate, rightTop: rightTopCoordinate, count: 50, text: text) {
            [weak self] photos in
            self?.fetchImages(photos: photos){
                if let strongSelf = self, strongSelf.searchingCoordinate == centerCoordinate {
                    strongSelf.mapView.addAnnotations(photos)
                    strongSelf.mapView.showAnnotations(photos, animated: true)
                    strongSelf.spinner.stopAnimating()
                    
                    completion?()
                }
            }
        }
    }
    
    /// PhotoクラスのiconImageURLで指定された画像を取ってくる。
    ///
    /// - parameter photos:     Photoの配列
    /// - parameter completion: 完了後に行う処理
    private func fetchImages(photos: [Photo], completion: @escaping () -> ()) {
        let group = DispatchGroup()
        
        let queue = DispatchQueue.global(qos: .userInitiated)
        
        for photo in photos {
            queue.async(group: group) {
                photo.fetchIconImage()
            }
        }
        
        group.notify(queue: DispatchQueue.main, execute: completion)
    }
    
    /// 経路を計算して描画する。
    ///
    /// - parameter source: 経路の出発地点
    /// - parameter dest:   経路の目的地
    /// - parameter animated: 経路全体をアニメーション表示するか
    /// - parameter completion: 完了時の処理
    func drawRoute(from source: MKAnnotation, to dest: MKAnnotation, animated: Bool, completion: (() -> ())? = nil) {
        let sourcePlacemark = MKPlacemark(coordinate: source.coordinate)
        let destPlacemark = MKPlacemark(coordinate: dest.coordinate)
        
        let sourceItem = MKMapItem(placemark: sourcePlacemark)
        let destItem = MKMapItem(placemark: destPlacemark)
        
        let request = MKDirectionsRequest()
        
        request.source = sourceItem
        request.destination = destItem
        request.requestsAlternateRoutes = false
        request.transportType = .walking
        
        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            if let error = error {
                log?.error(error)
                return
            }
            guard let response = response else { return }
            
            if response.routes.isEmpty {
                return
            }
            
            self.clearRoute()
            
            if let route = response.routes.first {
                self.mapView.add(route.polyline)
                
                let distanceFormatter = MKDistanceFormatter()
                distanceFormatter.units = .metric
                let distance = distanceFormatter.string(fromDistance: route.distance)
                
                if let time = route.expectedTravelTime.string {
                    self.routeDurationLabel.text = "\(distance) \(time)"
                }
                
                if animated {
                    let boundingRect = route.polyline.boundingMapRect
                    let rect = MKMapRectInset(boundingRect, -boundingRect.size.width / 10.0, -boundingRect.size.height / 10.0)
                    self.mapView.setVisibleMapRect(rect, animated: true)
                }
            }
            
            completion?()
        }
    }
    
    private func clearRoute() {
        mapView.removeOverlays(mapView.overlays)
        routeDurationLabel.text = " "
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        
        // 地図の初期表示位置の設定
        let center = CLLocationCoordinate2DMake(35.681382, 139.766084)
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        mapView.region = MKCoordinateRegionMake(center, span)
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ShowImageSegueIdentifier {
            guard let viewController = segue.destination as? ImageViewController else { fatalError() }
            guard let annotation = (sender as? MKAnnotationView)?.annotation as? Photo else { return }
            viewController.photo = annotation
            viewController.photos = mapView.annotations.map { $0 as? Photo }.flatMap { $0 }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.searchBar.isFirstResponder {
            self.searchBar.resignFirstResponder()
        }
    }


}
