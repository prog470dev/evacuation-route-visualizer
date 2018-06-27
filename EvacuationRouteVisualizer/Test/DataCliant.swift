//
//  DataCliant.swift
//  EvacuationRouteVisualizer
//
//  Created by 清水大樹 on 2018/05/18.
//  Copyright © 2018 prog470dev. All rights reserved.
//

import Foundation
import MapKit

class DataCliant {
    
    static let instance = DataCliant()
    
    var evacueeSet: Set<String> = Set<String>() //これいる？（ハッシュマップevacueeで存在判定はできそう）
    var evacuees: [String:Evacuee] = [:]
    
    private init(){
        Timer.scheduledTimer(timeInterval: 0.1,
                             target: self,
                             selector: #selector(DataCliant.dbRequest(timer:)),
                             userInfo: nil,
                             repeats: true)
    }
    
    @objc func dbRequest(timer: Timer){
        let currentEvacuees: [(id: String, latitude: String, longitude: String)]!
        
        currentEvacuees = DBStub.instance.getList() //モック
    
        for var e in currentEvacuees {
            if(!evacueeSet.contains(e.id)){
                evacueeSet.insert(e.id)
            }

            evacuees.updateValue(Evacuee(id: e.id, latitude: CLLocationDegrees(e.latitude)!, longitude: CLLocationDegrees(e.longitude)!, type: 0/**/), forKey: e.id)
        }
        
    }
    
    func getCoordinate(id: String) -> CLLocationCoordinate2D{
        return CLLocationCoordinate2DMake((evacuees[id]?.latitude)!, (evacuees[id]?.longitude)!)
    }
    
    //NOTE: 呼び出すときはUUIDを引数に与える
    func registEvacuee(id: String, coordinate: CLLocationCoordinate2D){
        //TODO: 登録済みかどうかの確認
        var alreadyRegist = DBStub.instance.findID(id: id)
        
        guard !alreadyRegist else { return }
        
        //TODO: クライアントをDBへ登録（直接evacueesには登録しない）
        DBStub.instance.addCliant(id: id, latitude: String(coordinate.latitude), longitude: String(coordinate.longitude))
    }
}
