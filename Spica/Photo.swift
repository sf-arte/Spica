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
    /// 写真のユニークID
    let id : Int
    
    /// 写真の撮影者のユーザーID
    let owner : String
    
    /// 写真の撮影者のユーザー名
    let ownerName : String
    
    /// URL計算用
    private let secret : String
    private let server : Int
    private let farm : Int
    
    /// 写真のタイトル
    let photoTitle : String
    
    /// 写真の撮影場所の座標
    let coordinate : Coordinates
    
    private var baseURL : String {
        return "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret)"
    }
    
    /// 大きい画像のURL。長辺が2048pxの画像のURLを返す
    var largeImageURL : URL? {
        return URL(string: baseURL + "_k.jpg")
    }
    
    /// アイコン画像のURL。75x75pxの画像のURLを返す
    var iconImageURL : URL? {
        return URL(string: baseURL + "_s.jpg")
    }
    
    init(id: Int, owner: String, ownerName: String, secret: String, server: Int, farm: Int, photoTitle: String, coordinate: Coordinates) {
        self.id = id
        self.owner = owner
        self.ownerName = ownerName
        self.secret = secret
        self.server = server
        self.farm = farm
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

typealias Coordinates = CLLocationCoordinate2D
