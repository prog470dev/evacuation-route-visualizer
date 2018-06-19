//
//  ApiClient.swift
//  EvacuationRouteVisualizer
//
//  Created by 清水大樹 on 2018/06/20.
//  Copyright © 2018 prog470dev. All rights reserved.
//

import Foundation
import MapKit
import Alamofire
import SwiftyJSON

class ApiClient {
    static let instance = ApiClient()
    
    var evacueeSet: Set<String> = Set<String>() //これいる？（ハッシュマップevacueeで存在判定はできそう）
    var evacuees: [String:Evacuee] = [:]
    
    private init(){
        Timer.scheduledTimer(timeInterval: 0.1,
                             target: self,
                             selector: #selector(ApiClient.dbRequest(timer:)),
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
            
            evacuees.updateValue(Evacuee(id: e.id, latitude: CLLocationDegrees(e.latitude)!, longitude: CLLocationDegrees(e.longitude)!), forKey: e.id)
        }
        
        
        //APIテスト
        let url = "https://goapp1-207110.appspot.com/getUser"
        Alamofire.request(url, method: .get).responseJSON(completionHandler: {response in
            
            guard let object = response.result.value else {
                return
            }
            
            let json = JSON(object)

//            print(json)
            for e in json {
                print("=====")
                print(e.0)
                print(e.1["id"])
            }
//
            
        })
        
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
