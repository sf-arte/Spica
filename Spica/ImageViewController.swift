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
        }
    }

    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.contentSize = imageView.frame.size
            scrollView.delegate = self
            scrollView.minimumZoomScale = 0.03
            scrollView.maximumZoomScale = 1.0
        }
    }
   
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    /// 画像の取得
    private func fetchImage() {
        guard let url = photo?.urls.largeImageURL else { return }
        spinner?.startAnimating()
        DispatchQueue.global(qos: .userInitiated).async {
            var contentsOfURL : Data? = nil
            do {
                contentsOfURL = try Data(contentsOf: url)
            } catch let error {
                log?.error(error)
            }
            DispatchQueue.main.async {
                if url == self.photo?.urls.largeImageURL, let contents = contentsOfURL {
                    self.image = UIImage(data: contents)
                }
                self.spinner?.stopAnimating()
            }

        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
