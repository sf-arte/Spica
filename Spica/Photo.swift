//
//  PhotoData.swift
//  Spica
//
//  Created by Suita Fujino on 2016/09/28.
//  Copyright © 2016年 ARTE Co., Ltd. All rights reserved.
//

import SwiftyJSON

struct Photo {
    let id : Int
    let owner : String
    let secret : String
    let server : Int
    let farm : Int
    let title : String
    
    private var baseURL : String {
        return "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret)"
    }
    
    var largeImageURL : String {
        return baseURL + "_k.jpg"
    }
    
    var iconImageURL : String {
        return baseURL + "_s.jpg"
    }
    
    init(json: JSON){
        id = json["id"].intValue
        owner = json["owner"].stringValue
        secret = json["secret"].stringValue
        server = json["server"].intValue
        farm = json["farm"].intValue
        title = json["title"].stringValue
    }
    
}
