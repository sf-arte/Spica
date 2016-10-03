//
//  PhotoData.swift
//  Spica
//
//  Created by Suita Fujino on 2016/09/28.
//  Copyright © 2016年 ARTE Co., Ltd. All rights reserved.
//

struct Photo {
    var id : Int
    var owner : String
    var secret : String
    var server : Int
    var farm : Int
    var title : String
    
    private var baseURL : String {
        let str = ("https://farm" + String(farm) + ".staticflickr.com/") + (String(server) + "/" + String(id)) + ("_" + secret)
        return str
    }
    
    var largeImageURL : String {
        return baseURL + "_k.jpg"
    }
    
    var iconImageURL : String {
        return baseURL + "_s.jpg"
    }
    
}
