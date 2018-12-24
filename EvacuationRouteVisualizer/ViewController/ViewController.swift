//
//  ViewController.swift
//  EvacuationRouteVisualizer
//
//  Created by 清水大樹 on 2018/05/18.
//  Copyright © 2018 prog470dev. All rights reserved.
//

import UIKit
import MapKit
import NVActivityIndicatorView
import SCLAlertView

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    var mapView: MKMapView!
    var myLocationManager: CLLocationManager!
    
    var evacueeSet: Set<String> = []    //同じピンを複数登録しないために設定するが、ハッシュマップだけでやりたい
    var evacueeHash: [String:MKPointAnnotation] = [:]
    
    var preType: [String:Int] = [:] //一つ前の画像を記憶 (登録済みtypeが変更されたときの対処のため)
    
    let uuid = UserDataManager.instance.ownID
    
    var count = 0 //ログ書き込み頻度の制限
    
    let logButton = UIButton()
    
    var indicatorView: NVActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //現在地の取得
        //myLocationManager = CLLocationManager()
        myLocationManager = UserDataManager.instance.myLocationManager
        myLocationManager.delegate = self
        myLocationManager.distanceFilter = kCLDistanceFilterNone
        myLocationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        /* 設定画面ですでに許可を得ているためここでは許可取得処理をしない */
        //TODO: 何かしらのエラーメッセージを表示する（クラッシュさせない）
//        let status = CLLocationManager.authorizationStatus()
//        if(status != CLAuthorizationStatus.authorizedWhenInUse) {
//            print("not determined")
//            myLocationManager.requestWhenInUseAuthorization()
//        }
//        myLocationManager.startUpdatingLocation()
        
        // MapViewの生成.
        mapView = MKMapView()
        mapView.frame = self.view.bounds
        mapView.delegate = self
        self.view.addSubview(mapView)
        
        // 中心点の緯度経度.
        let myLat: CLLocationDegrees = (myLocationManager.location?.coordinate.latitude)!
        let myLon: CLLocationDegrees = (myLocationManager.location?.coordinate.longitude)!
        let myCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(myLat, myLon)
        
        // 縮尺.
        let myLatDist : CLLocationDistance = 1000
        let myLonDist : CLLocationDistance = 1000
        let myRegion: MKCoordinateRegion = MKCoordinateRegionMakeWithDistance(myCoordinate, myLatDist, myLonDist);
        mapView.setRegion(myRegion, animated: true)
        
        //画面の更新
        Timer.scheduledTimer(timeInterval: 0.5,
                             target: self,
                             selector: #selector(ViewController.onUpdate(timer:)),
                             userInfo: nil,
                             repeats: true)

        //ログ送信ボタン出現のための隠しコマンド (２本指で連続５回タップ)
        let longTap = UITapGestureRecognizer(target: self, action: #selector(ViewController.longTapGesture(sender:)))
        longTap.numberOfTouchesRequired = 2
        longTap.numberOfTapsRequired = 5
        self.view.addGestureRecognizer(longTap)

        //ログ送信ボタンの設定
        let bWidth: CGFloat = 100
        let bHeight: CGFloat = 100
        let posX: CGFloat = 0
        let posY: CGFloat = self.view.frame.height - 100
        logButton.frame = CGRect(x: posX, y: posY, width: bWidth, height: bHeight)
        logButton.backgroundColor = UIColor.gray
        logButton.setTitle("Send Log", for: .normal)
        logButton.addTarget(self, action: #selector(ViewController.onClickLogButton(sender:)), for: .touchUpInside)
        
        /* 避難所の表示 */
        let shelterPin: MKPointAnnotation = EvacueeMKPointAnnotation(id: "0", type: 2)  //0:人, 1:モノ, 2: 避難所
        let shelterLat: CLLocationDegrees = UserDataManager.instance.shelterLatitude
        let shelterLon: CLLocationDegrees = UserDataManager.instance.shelterLongitude
        let center: CLLocationCoordinate2D = CLLocationCoordinate2DMake(shelterLat, shelterLon)
        shelterPin.coordinate = center
        shelterPin.title = "避難所"
        shelterPin.subtitle = "ゴール"
        mapView.addAnnotation(shelterPin)   //避難所もハッシュに入れないと表示されない
        evacueeSet.insert("0")
        evacueeHash.updateValue(shelterPin, forKey: "0")
        
        /* 自分の登録 */
        if(myLocationManager.location != nil){
            ApiClient.instance.registEvacuee(id: uuid, coordinate: (myLocationManager.location?.coordinate)!)
        }
        
        indicatorView = NVActivityIndicatorView(frame: CGRect(x: self.view.frame.width/2 - 50, y: self.view.frame.height/2 - 50, width: 100, height: 100),
                                                type: NVActivityIndicatorType.circleStrokeSpin,
                                                color: UIColor.white)
    }
    
    @objc func longTapGesture(sender: UISwipeGestureRecognizer){
        self.view.addSubview(logButton)
    }
    
    @objc func onClickLogButton(sender: UIButton) {
        print("send log.")
        ApiClient.instance.sendLog(waiting: {
                                    print("waiting...")
                                    self.view.addSubview(self.indicatorView)
                                    self.indicatorView.startAnimating()
        },
                                   successCompletion: {
                                    print("successCompletion")
                                    self.indicatorView.stopAnimating()
                                    self.indicatorView.removeFromSuperview()
                                    SCLAlertView().showInfo("送信完了", subTitle: "ログが送信されました。")
        },
                                   eorrorCompletion: {
                                    print("eorrorCompletion")
                                    self.indicatorView.stopAnimating()
                                    self.indicatorView.removeFromSuperview()
                                    SCLAlertView().showInfo("送信失敗", subTitle: "もう一度ログを送信してください。")
        })
        sender.removeFromSuperview()
    }
    
    
    @objc func onUpdate(timer: Timer){
        
        guard UserDataManager.instance.isStart else { return } //初期設定が完了しているときのみ実行
        
        count += 1
        if(count % 10 == 0){ //ファイルに書き込み (５秒に１回)
            count = 0
            
            let now = NSDate()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
            let timeStr = formatter.string(from: now as Date)
            
            //TODO: nilになっていた場合に発生するログデータの欠損はどうする？
            if(myLocationManager.location != nil){
                let str = timeStr + "," + "\(myLocationManager.location?.coordinate.latitude as! Double)" + "," + "\(myLocationManager.location?.coordinate.longitude as! Double)"
                
                let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last?.appendingPathComponent(UserDataManager.instance.getLogFileName())
                UserDataManager.instance.appendText(fileURL: path!, string: str)
            }
        }

        if(myLocationManager.location != nil){  //一旦バックグラウンドにすると一瞬nilになる
            //自分の登録
            ApiClient.instance.registEvacuee(id: uuid, coordinate: (myLocationManager.location?.coordinate)!)
        }
        
        for var e in ApiClient.instance.evacuees {
            //実行モードにごとのフィルタリング
            switch UserDataManager.instance.group {
            case 1: //自分のみ表示
                if(e.value.type==1 || (e.value.type==0 && e.value.id != uuid)){
                    continue
                }
            case 2: //自分と他人のみ表示
                if(e.value.type == 1){
                    continue
                }
            case 3: break //すべて表示
                //print("case 3. show all...")
            default:
                print("ERROR!!")
            }
        
            if (evacueeSet.contains(e.key)) {
                
                if(preType[e.key] != e.value.type){
                    /* 登録済みピンのタイプ変更が変更されていたときの処理 (mapView.addAnnotation呼び出し時のみしか変更できない) */
                    let oldPin = evacueeHash[e.key]
                    mapView.removeAnnotation(oldPin!)
                    
                    let newPin: MKPointAnnotation = EvacueeMKPointAnnotation(id: e.value.id, type: e.value.type)
                    let center: CLLocationCoordinate2D = CLLocationCoordinate2DMake(e.value.latitude, e.value.longitude)
                    newPin.coordinate = center
                    newPin.title = e.value.id
                    mapView.addAnnotation(newPin)
                    evacueeHash.updateValue(newPin, forKey: e.key)
                }else{
                    /* すでに表示済みなら座標の変更のみ */
                    let pin = evacueeHash[e.key]
                    var center: CLLocationCoordinate2D = CLLocationCoordinate2DMake(e.value.latitude, e.value.longitude)
                    
                    if(e.key == UserDataManager.instance.ownID){    //自分の更新のみローカルデータを使用
                        if(myLocationManager.location != nil){  //一旦バックグラウンドにすると一瞬nilになる
                            center = (myLocationManager.location?.coordinate)!
                        }
                    }
                    
                    pin?.coordinate = center
                    evacueeHash.updateValue(pin!, forKey: e.key)
                }
                
                preType.updateValue(e.value.type, forKey: e.key)
            }else{
                let pin: MKPointAnnotation = EvacueeMKPointAnnotation(id: e.value.id, type: e.value.type)
                let center: CLLocationCoordinate2D = CLLocationCoordinate2DMake(e.value.latitude, e.value.longitude)
                pin.coordinate = center
                pin.title = e.value.id
                mapView.addAnnotation(pin)
                evacueeSet.insert(e.key)
                evacueeHash.updateValue(pin, forKey: e.key)
                
                preType.updateValue(e.value.type, forKey: e.key)
            }
            
        }
        
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        print("regionDidChangeAnimated")
    }
    // 認証が変更された時に呼び出されるメソッド.
    private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status{
        case .authorizedWhenInUse:
            print("AuthorizedWhenInUse")
        case .authorized:
            print("Authorized")
        case .denied:
            print("Denied")
        case .restricted:
            print("Restricted")
        case .notDetermined:
            print("NotDetermined")
        case .authorizedAlways:
            print(".authorizedAlways")
        }
    }
    
    
    /* ピン画像の変更 */
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        //NOTE: mapView.addAnnotation(pin) のときに呼ばれる => pin: MKPointAnnotation(: MKAnnotation)
        
        let retAnnotation = MKAnnotationView()
        retAnnotation.annotation = annotation
        
        if let e = annotation as? EvacueeMKPointAnnotation{
            if(e.type == 0){ //人
                if(e.id == uuid){  //自分を判定
                    retAnnotation.image = UIImage(named: "annotation")!
                }else{
                    retAnnotation.image = UIImage(named: "annotation_other")!
                }
            }else if(e.type == 1) {  //モノ
                retAnnotation.image = UIImage(named: "obstacle")!
            }else{  //ゴール
                retAnnotation.image = UIImage(named: "shelter")!
            }
            
            (annotation as? EvacueeMKPointAnnotation)?.id = e.id    //タップ時のタイトル表示
            (annotation as? EvacueeMKPointAnnotation)?.title = e.id
            
            retAnnotation.annotation = annotation
            retAnnotation.canShowCallout = true //タップ時の反応を有効化
        }
        
        return  retAnnotation
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

