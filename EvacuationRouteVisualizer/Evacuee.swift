//
//  Evacuee.swift
//  EvacuationRouteVisualizer
//
//  Created by 清水大樹 on 2018/05/18.
//  Copyright © 2018 prog470dev. All rights reserved.
//

import Foundation
import MapKit

//TODO:
class Evacuee2 {
    
    let id: String!
    var latitude: CLLocationDegrees!
    var longitude: CLLocationDegrees!
    
    init(id: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees){
        self.id = id
        self.latitude = latitude
        self.longitude = longitude
    }
}
