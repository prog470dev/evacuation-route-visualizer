//
//  DBStub.swift
//  EvacuationRouteVisualizer
//
//  Created by 清水大樹 on 2018/05/19.
//  Copyright © 2018 prog470dev. All rights reserved.
//

import Foundation

class DBStub {
    
    //TEST: 更新テストのためのカウンタ
    var count = 0
    
    static let instance = DBStub()
    
    private var table: [(id: String, latitude: String, longitude: String)] = []
    
    private init(){
        
        //TEST: DBのテスト用更新
        addCliant(id: "100", latitude:"37.506804", longitude: "139.930531")
        Timer.scheduledTimer(timeInterval: 0.001,
                             target: self,
                             selector: #selector(DBStub.instance.onTestDBUpdate(timer:)),
                             userInfo: nil,
                             repeats: true)
    }
    
    //リストを返す
    func getList() -> [(id: String, latitude: String, longitude: String)]{
        return table
    }
    
    //新しクライアンとの登録
    func addCliant(id: String, latitude: String, longitude: String){
        table.append((id: id, latitude: latitude, longitude: longitude))
    }
    
    //idがすでに登録済みか返す
    func findID(id: String) -> Bool {
        for var e in table {
            if(e.id == id){
                return true
            }
        }
        return false
    }
    
    
    //TEST: DB更新テスト
    @objc func onTestDBUpdate(timer: Timer) {
        count += 1
        
        if(count == 3000){  //2人目出現
            addCliant(id: "200", latitude:"37.506804", longitude: "139.930583")
        }
        if(count == 6000){  //3人目出現
            addCliant(id: "300", latitude:"37.507804", longitude: "139.930392")
        }
        if(count == 7500){  //3人目出現
            addCliant(id: "400", latitude:"37.507804", longitude: "139.930692")
        }
        
        //ランダムウォーク
        let direction0: [Double] = [0.000001, 0.000001, 0.000002, -0.000002, -0.000001]
        let direction1: [Double] = [0.000001, 0.000001, -0.000001, 0.000000, -0.000001]
        for var i in 0..<table.count {
            var d0 = 0.0
            var d1 = 0.0
            if(arc4random() % 2 == 0){
                d0 = direction0[Int(arc4random() % 5)]
            }else{
                d1 = direction1[Int(arc4random() % 5)]
            }
            
            let lat = Double(table[i].latitude)! + d0
            let lon = Double(table[i].longitude)! + d1
            
            table[i].id = table[i].id
            table[i].latitude = String(lat)
            table[i].longitude = String(lon)
        }
        
    }
}
