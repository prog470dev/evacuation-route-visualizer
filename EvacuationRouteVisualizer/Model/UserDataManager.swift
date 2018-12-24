import UIKit
import MapKit

enum TypeValue: Int {
    case HUMAN = 0
    case OBJECT = 1
    case MISSING = -1
}

//TODO: 表示する物事に名前を変える
enum GroupValue: Int {
    case ONE = 1
    case TWO = 2
    case THREE = 3
    case MISSING = -1
}

enum AgeValue: Int {
    case GENERATION_10 = 10
    case GENERATION_20 = 20
    case GENERATION_30 = 30
    case GENERATION_40 = 40
    case GENERATION_50 = 50
    case GENERATION_60 = 60
    case GENERATION_70 = 70
    case GENERATION_80 = 80
    case MISSING = -1
}

enum SexValue: Int {
    case MALE = 0
    case FEMALE = 1
    case MISSING = -1
}

class UserDataManager {
    
    static let instance = UserDataManager()
    
    /* 自分の識別子 */
    let ownID = UIDevice.current.identifierForVendor!.uuidString
    
    var isStart = false //実験の実行状態
    
    var type = -1
    var group = -1
    var age = -1
    var sex = -1
    
    var shelterLatitude: Double = 1000.0    
    var shelterLongitude: Double = 1000.0
    
    let myLocationManager = CLLocationManager()
    
    private init(){}
    
    func startGettingLocation(){
        let status = CLLocationManager.authorizationStatus()
        print("status: ", status.rawValue)
        if(status != CLAuthorizationStatus.authorizedWhenInUse) {
            print("not determined")
            myLocationManager.requestWhenInUseAuthorization()
        }
        myLocationManager.startUpdatingLocation()
    }
    
    /* ログ・ファイル生成 */
    func createLog(fileName: String){

        let textFileName = getLogFileName()
        let initialText = "time,latitude,longitude"
        
        // DocumentディレクトリのfileURL
        if let documentDirectoryFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last {
            // ディレクトリのパスにファイル名をつなげてファイルのフルパス作成
            let targetTextFilePath = documentDirectoryFileURL.appendingPathComponent(textFileName)
            do {
                try initialText.write(to: targetTextFilePath, atomically: true, encoding: String.Encoding.utf8)
            } catch let error as NSError {
                print("failed to write: \(error)")
            }
        }
    }
    
    /* ログ・ファイル追記 */
    func appendText(fileURL: URL, string: String) {
        
        do {
            let fileHandle = try FileHandle(forWritingTo: fileURL)
            let stringToWrite = "\n" + string
            // ファイルの最後に追記
            fileHandle.seekToEndOfFile()
            fileHandle.write(stringToWrite.data(using: String.Encoding.utf8)!)
        } catch let error as NSError {
            print("failed to append: \(error)")
        }
    }

    func getLogFileName() -> String{
        let logFileName = ownID + "_" + String(type) + "_" + String(group) + "_" + String(age) + "_" + String(sex) + ".csv"
        return logFileName
    }
}
