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
            if view.window != nil {
                fetchImage()
            }
            titleLabel.text = photo?.title == "" ? " " : photo?.title
            userNameLabel.text = photo?.ownerName
        }
    }
    
    private var imageView = UIImageView()
    
    private var image: UIImage? {
        get {
            return imageView.image
        } set {
            imageView.image = newValue
            imageView.sizeToFit()
            scrollView?.contentSize = imageView.frame.size
            scrollView.minimumZoomScale = scrollView.frame.size.width / imageView.frame.size.width
            scrollView.zoomScale = scrollView.minimumZoomScale
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
    
    /// MARK: メソッド
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.addSubview(imageView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if image == nil {
            fetchImage()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        updateScrollInset()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateScrollInset()
    }
    
    /// 画像の取得
    private func fetchImage() {
        guard let url = photo?.urls.originalImageURL ?? photo?.urls.largeImageURL else { return }
        fetchingURL = url
        spinner?.startAnimating()
        DispatchQueue.global(qos: .userInitiated).async {
            var contentsOfURL : Data? = nil
            do {
                contentsOfURL = try Data(contentsOf: url)
            } catch let error {
                log?.error(error)
            }
            DispatchQueue.main.async {
                if url == self.fetchingURL, let contents = contentsOfURL {
                    self.image = UIImage(data: contents)
                }
                self.spinner?.stopAnimating()
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
