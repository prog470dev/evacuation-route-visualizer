import Foundation
import MapKit
import Alamofire
import SwiftyJSON

struct Evacuee {
    var id: String
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

struct Shelter {
    var latitude: Double
    var longitude: Double
    
    init(latitude: Double, longitude: Double){
        self.latitude = latitude
        self.longitude = longitude
    }
}

class ApiClient {
    static let instance = ApiClient()
    
    let dmain = Const.DOMAIN
    var evacueeSet: Set<String> = Set<String>() //これいる？（ハッシュマップevacueeで存在判定はできそう）
    var evacuees: [String:Evacuee] = [:]
    
    let intervalTime = 2.0
    
    private init(){
        Timer.scheduledTimer(timeInterval: intervalTime,
                             target: self,
                             selector: #selector(ApiClient.getLocations(timer:)),
                             userInfo: nil,
                             repeats: true)
    }
    
    /* 全ユーザの情報取得 */
    @objc func getLocations(timer: Timer){
        let url = "https://" + dmain + "/user"
        
        Alamofire.request(url, method: .get).responseJSON(completionHandler: {response in
            
            //レスポンスが正常でないときは無視 (無視しないと落ちる)
            guard response.response != nil else {
                print("response.response", response.response)
                return
            }
            let statusCode: Int = (response.response?.statusCode)!
            guard statusCode == 200 else {
                print("statusCode(@get)", statusCode)
                return
            }
            
            guard let data = response.result.value else {
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
        let url = "https://" + dmain + "/user"
        let parameters: [String: String] = [
            "id" : id,
            "latitude" : String("\(coordinate.latitude)"),
            "longitude" : String("\(coordinate.longitude)"),
            "type" : String("\(UserDataManager.instance.type)"),
        ]
    
        Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .responseJSON { response in
                //レスポンスが正常でないときは無視 (無視しないと落ちる)
                guard response.response != nil else {
                    print("response.response", response.response)
                    return
                }
                let statusCode: Int = (response.response?.statusCode)!
                guard statusCode == 200 else {
                    print("statusCode(@regist)", statusCode)
                    return
                }
                //TODO: 書き込み整合の確認
                guard let data = response.data else {
                    return
                }
        }
    }
    
    /* 避難所データの取得 */
    func getShelterInfo (){
        let url = "https://storage.googleapis.com/" + Const.DOMAIN + "/shelter.json"
        
        Alamofire.request(url, method: .get).responseJSON(completionHandler: {response in
            
            guard let data = response.result.value else {
                return
            }
            
            let json = JSON(data)
            
            let shelter = Shelter(latitude: json.dictionary!["shelter"]!.dictionaryObject!["latitude"] as! Double,
                                  longitude: json.dictionary!["shelter"]!.dictionaryObject!["longitude"] as! Double)
            
            UserDataManager.instance.shelterLatitude = shelter.latitude
            UserDataManager.instance.shelterLongitude = shelter.longitude
            
            print("UserDataManager.instance.shelterLatitude:", UserDataManager.instance.shelterLatitude)
        })
    }
    
    /* 座標ログの送信 */
    func sendLog(waiting: (() -> ())?, successCompletion: (() -> ())?, eorrorCompletion: (() -> ())?){
        
        waiting?()
        
        let textFileName = UserDataManager.instance.getLogFileName()
        //ファイルアップロード
        let path = FileManager.default.urls(for: .documentDirectory/*.libraryDirectory*/, in: .userDomainMask).first?.appendingPathComponent(textFileName)    //作成したファイルのパス検索
      
        if(FileManager.default.fileExists(atPath: (path?.path)!)) { //ファイルの存在を確認
            do {
                let data = try Data(contentsOf: path!)
                let url = "https://" + dmain + "/log"
                
                Alamofire.upload(
                    multipartFormData: { multipartFormData in
                        // パラーメータ指定(ファイルもテキストも行ける?)
                        multipartFormData.append(data, withName: "file", fileName: textFileName, mimeType: "text/csv")
                    },
                    to: url,
                    encodingCompletion: { encodingResult in
                        switch encodingResult {
                        case .success(let upload, _, _):
                            upload.responseJSON { response in
                                
                                if response == nil {
                                    eorrorCompletion?()
                                    return
                                }
                                
                                if response.response != nil {
                                    let statusCode: Int = (response.response?.statusCode)!
                                    if statusCode == 200 {
                                        //成功時の処理
                                        successCompletion?()
                                    }else{
                                        //失敗時の処理
                                        eorrorCompletion?()
                                    }
                                }else{
                                    //失敗時の処理
                                    eorrorCompletion?()
                                }
                            }
                        case .failure(let encodingError):
                            //失敗時の処理
                            eorrorCompletion?()
                        }
                })

            } catch {
                //失敗時の処理
                eorrorCompletion?()
            }
        }else{
            print("NOT FOUND!!")
            //失敗時の処理
            eorrorCompletion?()
        }
    }
    

}
