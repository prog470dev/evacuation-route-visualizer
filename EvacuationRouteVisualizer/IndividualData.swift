//
//  IndividualData.swift
//  EvacuationRouteVisualizer
//
//  Created by 清水大樹 on 2018/05/19.
//  Copyright © 2018 prog470dev. All rights reserved.
//

import Foundation

class IndividualAttribute {
    
    static let instance = IndividualAttribute()
    
    let ownID = NSUUID().uuidString //この識別子を使用して自分を判断する（ex. マップ上のピンの色を変えるとか）
    
    private init(){
    }
    
    
}
