//
//  UserData.swift
//  EvacuationRouteVisualizer
//
//  Created by 清水大樹 on 2018/06/27.
//  Copyright © 2018 prog470dev. All rights reserved.
//

import UIKit

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
    
    let ownID = UIDevice.current.identifierForVendor!.uuidString //この識別子を使用して自分を判断する（ex. マップ上のピンの色を変えるとか）
    
    var isStart = false //実験の実行状態
    
    var type = -1
    var group = -1
    var age = -1
    var sex = -1
    
    private init(){}
    
    //ログ・ファイル生成
    func createLog(fileName: String){
        // 作成するテキストファイルの名前
        let textFileName = getLogFileName()
        let initialText = "time,latitude,longitude"
        
        // DocumentディレクトリのfileURLを取得
        if let documentDirectoryFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last {
            // ディレクトリのパスにファイル名をつなげてファイルのフルパスを作る
            let targetTextFilePath = documentDirectoryFileURL.appendingPathComponent(textFileName)
            
            do {
                try initialText.write(to: targetTextFilePath, atomically: true, encoding: String.Encoding.utf8)
            } catch let error as NSError {
                print("failed to write: \(error)")
            }
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

    func getLogFileName() -> String{
        var logFileName = ""
        
        logFileName += ownID + "_" + String(type) + "_" + String(group) + "_" + String(age) + "_" + String(sex) + ".csv"
        
        return logFileName
    }
}
