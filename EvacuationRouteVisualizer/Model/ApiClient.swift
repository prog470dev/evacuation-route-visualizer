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
    
    var type: Int
    
    init(id: String, latitude: Double, longitude: Double, type: Int){
        self.id = id
        self.latitude = latitude
        self.longitude = longitude
        self.type = type
    }
}

class ApiClient {
    static let instance = ApiClient()
    
    let dmain = "kandeza81.appspot.com"
    
    var evacueeSet: Set<String> = Set<String>() //これいる？（ハッシュマップevacueeで存在判定はできそう）
    var evacuees: [String:Evacuee] = [:]
    
    private init(){
        Timer.scheduledTimer(timeInterval: 1.0,
                             target: self,
                             selector: #selector(ApiClient.getLocations(timer:)),
                             userInfo: nil,
                             repeats: true)
    }
    
    /* 全ユーザの情報取得 */
    @objc func getLocations(timer: Timer){
        
        let url = "https://" + dmain + "/getUser"
        
        Alamofire.request(url, method: .get).responseJSON(completionHandler: {response in
            
            let statusCode: Int = (response.response?.statusCode)!
            guard statusCode == 200 else { return } //レスポンスが正常でないときは無視 (無視しないと落ちる)
            
            guard let data = response.result.value else {   //[?] ここの処理の必要性は？
                return
            }

            let json = JSON(data)
            for e in json {
                var eva = Evacuee(id: e.1["id"].string!,
                                  latitude: e.1["latitude"].double!,
                                  longitude: e.1["longitude"].double!,
                                  type: e.1["type"].int!)
                self.evacuees.updateValue(eva, forKey: e.1["id"].string!)
            }
            
        })
    }
    
    func getCoordinate(id: String) -> CLLocationCoordinate2D{
        return CLLocationCoordinate2DMake((evacuees[id]?.latitude)!, (evacuees[id]?.longitude)!)
    }
    
    /* 自分の現在地登録 */
    func registEvacuee(id: String, coordinate: CLLocationCoordinate2D){
        
        var url = "https://" + dmain + "/setUser?"
        url += "id=" + id
        url += "&latitude=" + String("\(coordinate.latitude)")
        url += "&longitude=" + String("\(coordinate.longitude)")
        url += "&type=" + String("\(UserDataManager.instance.type)")  //アプリのバージョンによるスクリーニングに使用
        
        Alamofire.request(url, method: .get).responseJSON(completionHandler: {response in
            
            let statusCode: Int = (response.response?.statusCode)!
            guard statusCode == 200 else { return } //レスポンスが正常でないときは無視 (無視しないと落ちる)
            
            //TODO: 書き込み整合の確認
            guard let data = response.data else {
                return
            }
                    
        })
    }
    
    /* 座標ログの送信 */
    func sendLog(){
        let textFileName = UserDataManager.instance.getLogFileName()
        //ファイルアップロード
        let path = FileManager.default.urls(for: .documentDirectory/*.libraryDirectory*/, in: .userDomainMask).first?.appendingPathComponent(textFileName)    //作成したファイルのパス検索
      
        if(FileManager.default.fileExists(atPath: (path?.path)!)) { //ファイルの存在を確認
            do {
                let data = try Data(contentsOf: path!)
                let url = "https://" + dmain + "/upload"
                
                Alamofire.upload(
                    multipartFormData: { multipartFormData in
                        // パラーメータ指定(ファイルもテキストも行ける?)
                        multipartFormData.append(data, withName: "file", fileName: textFileName, mimeType: "text/csv")
                },
                    to: url,
                    encodingCompletion: { encodingResult in
//                        switch encodingResult {
//                        case .success(let upload, _, _):
//                            upload.responseJSON { response in
//                                // 成功
//                                let responseData = response
//                                print(responseData ?? "成功")
//                            }
//                        case .failure(let encodingError):
//                            // 失敗
//                            print(encodingError)
//                        }
                })

            } catch {
                print("err.......")
            }
        }else{
            print("NOT FOUND!!")
        }
    }
    

}
