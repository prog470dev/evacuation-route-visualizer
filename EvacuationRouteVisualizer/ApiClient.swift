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
    
    //全ユーザの情報取得
    @objc func getLocations(timer: Timer){
        
        //let url = "https://goapp1-207110.appspot.com/getUser"
        let url = "https://kandeza81.appspot.com/getUser"
        
        Alamofire.request(url, method: .get).responseJSON(completionHandler: {response in
            
            let statusCode: Int = (response.response?.statusCode)!
            //print("statusCode(@get): ", statusCode)
            guard statusCode == 200 else { return } //レスポンスが正常でないときは無視 (無視しないと落ちる)
            
            guard let data = response.result.value else {   //[?] ここの処理の必要性は？
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
    
    //自分の現在地登録
    func registEvacuee(id: String, coordinate: CLLocationCoordinate2D){
        
        //var url = "https://goapp1-207110.appspot.com/setUser?"
        var url = "https://kandeza81.appspot.com/setUser?"
        url += "id=" + id
        url += "&latitude=" + String("\(coordinate.latitude)")
        url += "&longitude=" + String("\(coordinate.longitude)")
        
        Alamofire.request(url, method: .get).responseJSON(completionHandler: {response in
            
            let statusCode: Int = (response.response?.statusCode)!
            //print("statusCode(@set): ", statusCode)
            guard statusCode == 200 else { return } //レスポンスが正常でないときは無視 (無視しないと落ちる)
            
            //TODO: 書き込み整合の確認
            guard let data = response.data else {
                return
            }
                    
        })
    }
    
    //座標ログの送信 (TODO: 起動時[or 実験開始時]にローカルのログは全削除?)
    func sendLog(){
        let textFileName = "test.csv" //TODO: メモリ上の値からファイル名を生成
        //createLog(fileName: textFileName)
        
        //追記テスト
        appendText(fileURL: (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(textFileName))!
            , string: "DDD,DDD,DDD")
        
        //ファイルアップロード
        let path = FileManager.default.urls(for: .documentDirectory/*.libraryDirectory*/, in: .userDomainMask).first?.appendingPathComponent(textFileName)    //作成したファイルのパス検索
      
        if(FileManager.default.fileExists(atPath: (path?.path)!)) { //ファイルの存在を確認
            do {
                let data = try Data(contentsOf: path!)
                let url = "https://kandeza81.appspot.com/upload"
                
                Alamofire.upload(
                    multipartFormData: { multipartFormData in
                        // パラーメータ指定(ファイルもテキストも行ける?)
                        multipartFormData.append(data, withName: "file", fileName: "test.csv", mimeType: "text/csv")
                        //multipartFormData.append(sendSTR.data(using: String.Encoding.utf8)!, withName: "userId")
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
    
    // テキストを追記するメソッド
    func appendText(fileURL: URL, string: String) {
        
        do {
            let fileHandle = try FileHandle(forWritingTo: fileURL)
            
            // 改行を入れる
            let stringToWrite = "\n" + string
            
            // ファイルの最後に追記
            fileHandle.seekToEndOfFile()
            fileHandle.write(stringToWrite.data(using: String.Encoding.utf8)!)
            
        } catch let error as NSError {
            print("failed to append: \(error)")
        }
    }
    
    //ログ・ファイル生成 (起動に/実験開始時にコール)
    func createLog(fileName: String){
        //ファイル生成(とりあえずここで作る)
        // 作成するテキストファイルの名前
        let textFileName = fileName
        let initialText = "AAA,BBB,CCC\nAAA,BBB,CCC\nAAA,BBB,CCC"
        
        // DocumentディレクトリのfileURLを取得
        if let documentDirectoryFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last {
            
            // ディレクトリのパスにファイル名をつなげてファイルのフルパスを作る
            let targetTextFilePath = documentDirectoryFileURL.appendingPathComponent(textFileName)
            
            print("書き込むファイルのパス: \(targetTextFilePath)")
            
            do {
                try initialText.write(to: targetTextFilePath, atomically: true, encoding: String.Encoding.utf8)
            } catch let error as NSError {
                print("failed to write: \(error)")
            }
        }
    }
    

}
