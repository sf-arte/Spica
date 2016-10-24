//
//  Utility.swift
//  Spica
//
//  Created by Suita Fujino on 2016/10/11.
//  Copyright © 2016年 ARTE Co., Ltd. All rights reserved.
//

import MapKit

typealias Coordinates = CLLocationCoordinate2D

func == (lhs: Coordinates, rhs: Coordinates) -> Bool{
    return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
}

extension TimeInterval {
    var string: String {
        get {
            let interval = Int(self)
            let dates = interval / 86400
            let hours = (interval % 86400) / 3600
            let minutes = (interval % 3600) / 60
            
            if dates > 0 {
                return "\(dates)日\(hours)時間"
            } else if hours > 0 {
                return "\(hours)時間\(minutes)分"
            } else {
                return "\(minutes)分"
            }
        }
    }
}
