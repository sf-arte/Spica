//
//  PhotoData.swift
//  Spica
//
//  Created by Suita Fujino on 2016/09/28.
//  Copyright © 2016年 ARTE Co., Ltd. All rights reserved.
//

struct PhotoData {
    var id : Int
    var owner : String
    var secret : String
    var server : Int
    var farm : Int
    var title : String
    
    private var baseURL : String {
        var str = "https://farm" + String(farm) + ".staticflickr.com/"
        str.append(String(server) + "/" + String(id))
        str.append("_" + secret)
        return str
    }
    
    var URLforLargeImage : String {
        return baseURL + "_k.jpg"
    }
    
    var URLforIconImage : String {
        return baseURL + "_s.jpg"
    }
    
}
