//
//  PhotoData.swift
//  Spica
//
//  Created by Suita Fujino on 2016/09/28.
//  Copyright © 2016年 ARTE Co., Ltd. All rights reserved.
//

import SwiftyJSON
import MapKit

/**
 
 JSONをパースして得られた写真の情報を格納するクラス
 
*/
class Photo : NSObject{
    
    /// URL計算用struct
    struct URLGenerator {
        /*
        let secret : String
        let server : Int
        let farm : Int
        let id : Int
        
        private var baseURL : String {
            return "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret)"
        }
         */
        
        /// オリジナルの画像のURL
        var originalImageURL : URL?
        
        /// 長辺1024pxの画像のURL
        var largeImageURL : URL?
        
        /// アイコン画像のURL。75x75pxの画像のURLを返す
        var iconImageURL : URL?
    }
    
    /// 画像の各サイズのURL
    let urls : URLGenerator
    
    /// 写真のユニークID
    let id : Int
    
    /// 写真の撮影者のユーザーID
    let owner : String
    
    /// 写真の撮影者のユーザー名
    let ownerName : String
    
    /// 写真のタイトル
    let photoTitle : String
    
    /// 写真の撮影場所の座標
    let coordinate : Coordinates
    
    /// アイコンの画像
    var iconImage : UIImage? = nil
    
    
    
    init(id: Int, owner: String, ownerName: String, iconURL: String, largeURL: String, originalURL: String, photoTitle: String, coordinate: Coordinates) {
        self.urls = URLGenerator(originalImageURL: URL(string: originalURL), largeImageURL: URL(string: largeURL), iconImageURL: URL(string: iconURL))
        self.id = id
        self.owner = owner
        self.ownerName = ownerName
        self.photoTitle = photoTitle
        self.coordinate = coordinate
    }

    
}

extension Photo : MKAnnotation {
    var title : String? {
        return photoTitle
    }
    
    var subtitle : String? {
        return ownerName
    }
}



