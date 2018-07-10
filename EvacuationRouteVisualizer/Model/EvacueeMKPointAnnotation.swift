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
    var type: Int!
    
    init(id: String, type: Int){
        self.id = id
        self.type = type    //0:人, 1:モノ, 2: 避難所
    }
}
