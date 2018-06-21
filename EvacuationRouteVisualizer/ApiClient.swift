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

struct Evacuee {
    let id: String
    var latitude: Double
    var longitude: Double
    
    init(id: String, latitude: Double, longitude: Double){
        self.id = id
        self.latitude = latitude
        self.longitude = longitude
    }
}

class ApiClient {
    static let instance = ApiClient()
    
    var evacueeSet: Set<String> = Set<String>() //これいる？（ハッシュマップevacueeで存在判定はできそう）
    var evacuees: [String:Evacuee] = [:]
    
    private init(){
        Timer.scheduledTimer(timeInterval: 1.0,
                             target: self,
                             selector: #selector(ApiClient.getLocations(timer:)),
                             userInfo: nil,
                             repeats: true)
    }
    
    @objc func getLocations(timer: Timer){
        
        let url = "https://goapp1-207110.appspot.com/getUser"
        Alamofire.request(url, method: .get).responseJSON(completionHandler: {response in
            
            guard let data = response.result.value else {
                return
            }

            let json = JSON(data)
            for e in json {
                var eva = Evacuee(id: e.1["id"].string!,
                                  latitude: e.1["latitude"].double!,
                                  longitude: e.1["longitude"].double!)
                self.evacuees.updateValue(eva, forKey: e.1["id"].string!)
            }
            
        })
        
    }
    
    func getCoordinate(id: String) -> CLLocationCoordinate2D{
        return CLLocationCoordinate2DMake((evacuees[id]?.latitude)!, (evacuees[id]?.longitude)!)
    }
    
    //NOTE: 呼び出すときはUUIDを引数に与える
    func registEvacuee(id: String, coordinate: CLLocationCoordinate2D){
//        //TODO: 登録済みかどうかの確認
//        var alreadyRegist = DBStub.instance.findID(id: id)
//        guard !alreadyRegist else { return }
//        //TODO: クライアントをDBへ登録（直接evacueesには登録しない）
//        DBStub.instance.addCliant(id: id, latitude: String(coordinate.latitude), longitude: String(coordinate.longitude))
        
        //自分をDBに登録
        //APIテスト
        var url = "https://goapp1-207110.appspot.com/setUser?"
        url += "id=" + id
        url += "&latitude=" + String("\(coordinate.latitude)")
        url += "&longitude=" + String("\(coordinate.longitude)")
        
        print("url: ", url)
        
        Alamofire.request(url, method: .get).responseJSON(completionHandler: {response in
            
            //TODO: 書き込み整合の確認
            guard let data = response.data else {
                return
            }
                    
        })
    }
    
}
