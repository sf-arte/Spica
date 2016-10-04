//
//  PhotoData.swift
//  Spica
//
//  Created by Suita Fujino on 2016/09/28.
//  Copyright © 2016年 ARTE Co., Ltd. All rights reserved.
//

import SwiftyJSON

/**
 
 JSONをパースして得られた写真の情報を格納するクラス
 
*/
struct Photo {
    /// 写真のユニークID
    let id : Int
    
    /// 写真の撮影者のユーザーID
    let owner : String
    
    /// URL計算用
    private let secret : String
    private let server : Int
    private let farm : Int
    
    /// 写真のタイトル
    let title : String
    
    private var baseURL : String {
        return "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret)"
    }
    
    /// 大きい画像のURL。長辺が2048pxの画像のURLを返す
    var largeImageURL : String {
        return baseURL + "_k.jpg"
    }
    
    /// アイコン画像のURL。75x75pxの画像のURLを返す
    var iconImageURL : String {
        return baseURL + "_s.jpg"
    }
    
    /**
     - parameter json: パース後のJSONデータ
     */
    init(json: JSON){
        id = json["id"].intValue
        owner = json["owner"].stringValue
        secret = json["secret"].stringValue
        server = json["server"].intValue
        farm = json["farm"].intValue
        title = json["title"].stringValue
    }
    
}
