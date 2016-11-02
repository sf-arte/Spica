//
//  ImageViewController.swift
//  Spica
//
//  Created by Suita Fujino on 2016/10/17.
//  Copyright © 2016年 ARTE Co., Ltd. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController, UIScrollViewDelegate {
    
    /// MARK: プロパティ
    
    var photo : Photo? {
        didSet {
            image = nil
            
            if view.window != nil {
                fetchImage()
            }
            
            titleLabel.text = photo?.title == "" ? " " : photo?.title
            userNameLabel.text = photo?.ownerName
        }
    }
    
    var photos : [Photo]?
    
    /// ダウンロードした画像を格納する
    private var imageHolder : [URL : UIImage] = [:]
    
    private var imageView = UIImageView()
    
    private var image: UIImage? {
        get {
            return imageView.image
        } set {
            scrollView?.zoomScale = 1.0
            imageView.image = newValue
            imageView.sizeToFit()
            if let image = newValue {
                scrollView?.contentSize = imageView.frame.size
                scrollView.minimumZoomScale = min(scrollView.frame.size.height / image.size.height, scrollView.frame.size.width / image.size.width)
                scrollView.zoomScale = scrollView.minimumZoomScale
                updateScrollInset()
            }
        }
    }
    
    private var fetchingURL : URL?

    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.contentSize = imageView.frame.size
            scrollView.delegate = self
            scrollView.minimumZoomScale = 1.0
            scrollView.maximumZoomScale = 2.0
        }
    }
   
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var routeButton: UIButton! {
        didSet {
            routeButton.accessibilityIdentifier = "Route Button"
        }
    }
    
    /// MARK: メソッド
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.addSubview(imageView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(onOrientationChanging(notification:)), name: .UIDeviceOrientationDidChange, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if image == nil {
            fetchImage()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /// スワイプ時の処理
    @IBAction func recognizeSwipe(_ sender: UISwipeGestureRecognizer) {
        guard let photo = photo,
            let photos = photos,
            let index = photos.index(of: photo) else { return }
        
        let count = photos.count
        
        if sender.direction == .right {
            if index + 1 < count {
                self.photo = photos[index + 1]
            }
        } else if sender.direction == .left {
            if index - 1 >= 0 {
                self.photo = photos[index - 1]
            }
        }
    }
    
    /// ダブルタップの処理
    @IBAction func recognizeTap(_ sender: UITapGestureRecognizer) {
        let scale = scrollView.zoomScale == scrollView.minimumZoomScale ? 1.0 : scrollView.minimumZoomScale

        UIView.animate(withDuration: 0.5) {
            self.scrollView.zoomScale = scale
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateScrollInset()
    }
    
    func onOrientationChanging(notification: Notification) {
        if let image = image {
            scrollView.minimumZoomScale = min(scrollView.frame.size.height / image.size.height, scrollView.frame.size.width / image.size.width)
            
        }
    }
    
    /// 画像の取得
    private func fetchImage() {
        guard let url = photo?.urls.originalImageURL ?? photo?.urls.largeImageURL else { return }
        // 既に取得していたらそれを使う
        if let image = imageHolder[url] {
            self.image = image
            return
        }
        
        fetchingURL = url
        spinner?.startAnimating()
        
        DispatchQueue.global(qos: .userInitiated).async {
            var contentsOfURL : Data? = nil
            do {
                contentsOfURL = try Data(contentsOf: url)
            } catch let error {
                log?.error(error)
                self.spinner?.stopAnimating()
                return
            }
            DispatchQueue.main.async {
                if url == self.fetchingURL, let contents = contentsOfURL {
                    self.image = UIImage(data: contents)
                    self.imageHolder[url] = self.image
                    self.spinner?.stopAnimating()
                }
            }
        }
    }
    
    /// 画像を中央に持ってくるように調整
    private func updateScrollInset() {
        scrollView.contentInset = UIEdgeInsetsMake(
            max((scrollView.frame.height - imageView.frame.height) / 2, 0),
            max((scrollView.frame.width - imageView.frame.width) / 2, 0),
            0,
            0
        )
    }
    
}
