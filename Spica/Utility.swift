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
