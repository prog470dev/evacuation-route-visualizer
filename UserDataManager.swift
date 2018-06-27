//
//  UserData.swift
//  EvacuationRouteVisualizer
//
//  Created by 清水大樹 on 2018/06/27.
//  Copyright © 2018 prog470dev. All rights reserved.
//

import UIKit

class UserDataManager {
    
    static let instance = UserDataManager()
    
    let ownID = UIDevice.current.identifierForVendor!.uuidString //この識別子を使用して自分を判断する（ex. マップ上のピンの色を変えるとか）
    
    var executionMode = 3   //表示する対象に合わせたモード
    
    var isStart = true//false //実験の実行状態
    
    var type = -1
    var group = -1
    var age = -1
    var sex = -1
    
    var logFileName = "ID_TYPE_GROUP_AGE_SEX.csv"    //TODO: ユーザ情報から生成
    
    private init(){}
    
    //ログ・ファイル生成 (起動に/実験開始時にコール)
    func createLog(fileName: String){
        // 作成するテキストファイルの名前
        let textFileName = fileName
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
}
