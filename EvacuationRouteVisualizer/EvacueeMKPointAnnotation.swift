//
//  EvacueeMKPointAnnotation.swift
//  EvacuationRouteVisualizer
//
//  Created by 清水大樹 on 2018/05/19.
//  Copyright © 2018 prog470dev. All rights reserved.
//

import MapKit

class EvacueeMKPointAnnotation: MKPointAnnotation {
    var id: String!
    
    init(id: String){
        self.id = id
    }
}
