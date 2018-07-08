//
//  ViewController.swift
//  EvacuationRouteVisualizer
//
//  Created by 清水大樹 on 2018/05/18.
//  Copyright © 2018 prog470dev. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    var mapView: MKMapView!
    var myLocationManager: CLLocationManager!
    
    var evacueeSet: Set<String> = []    //同じピンを複数登録しないために設定するが、ハッシュマップだけでやりたい
    var evacueeHash: [String:MKPointAnnotation] = [:]
    
    let uuid = UserDataManager.instance.ownID
    
    var count = 0 //自分の座標登録の回数を制限するため
    
    let myButton = UIButton()   //ログ送信用ボタン
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //現在地の取得
        myLocationManager = CLLocationManager()
        myLocationManager.delegate = self
        myLocationManager.distanceFilter = kCLDistanceFilterNone//100.0
        myLocationManager.desiredAccuracy = kCLLocationAccuracyBest//kCLLocationAccuracyHundredMeters
        let status = CLLocationManager.authorizationStatus()
        if(status != CLAuthorizationStatus.authorizedWhenInUse) {
            print("not determined")
            myLocationManager.requestWhenInUseAuthorization()
        }
        myLocationManager.startUpdatingLocation()
        
        // MapViewの生成.
        mapView = MKMapView()
        mapView.frame = self.view.bounds
        mapView.delegate = self
        self.view.addSubview(mapView)
        
        // 中心点の緯度経度.
        let myLat: CLLocationDegrees = (myLocationManager.location?.coordinate.latitude)! //37.506804
        let myLon: CLLocationDegrees = (myLocationManager.location?.coordinate.longitude)! //139.930531
        let myCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(myLat, myLon)
        
        // 縮尺.
        let myLatDist : CLLocationDistance = 1000
        let myLonDist : CLLocationDistance = 1000
        let myRegion: MKCoordinateRegion = MKCoordinateRegionMakeWithDistance(myCoordinate, myLatDist, myLonDist);
        mapView.setRegion(myRegion, animated: true)
        
        //画面の更新
        Timer.scheduledTimer(timeInterval: 1.0,
                             target: self,
                             selector: #selector(ViewController.onUpdate(timer:)),
                             userInfo: nil,
                             repeats: true)

        //ログ送信ボタン出現のための隠しコマンド
        let longTap = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.longTapGesture(sender:)))
        longTap.minimumPressDuration = 5.0
        self.view.addGestureRecognizer(longTap)

        //ログ送信ボタンの設定
        let bWidth: CGFloat = 100
        let bHeight: CGFloat = 100
        let posX: CGFloat = 0
        let posY: CGFloat = self.view.frame.height - 100
        myButton.frame = CGRect(x: posX, y: posY, width: bWidth, height: bHeight)
        myButton.backgroundColor = UIColor.gray
        myButton.setTitle("Send Log", for: .normal)
        myButton.addTarget(self, action: #selector(ViewController.onClickMyButton(sender:)), for: .touchUpInside)
        
        
        /* 避難所の表示 */
        let shelterPin: MKPointAnnotation = EvacueeMKPointAnnotation(id: "0", type: 2)  //0:人, 1:モノ, 3: 避難所
        let shelterLat: CLLocationDegrees = 36.545413
        let shelterLon: CLLocationDegrees = 136.705706
        let center: CLLocationCoordinate2D = CLLocationCoordinate2DMake(shelterLat, shelterLon)
        shelterPin.coordinate = center
        shelterPin.title = "避難所"
        shelterPin.subtitle = "ゴール"
        mapView.addAnnotation(shelterPin)   //避難所もハッシュに入れないと表示されない
        evacueeSet.insert("0")
        evacueeHash.updateValue(shelterPin, forKey: "0")
        
    }
    
    @objc func longTapGesture(sender: UISwipeGestureRecognizer){
        self.view.addSubview(myButton)
    }
    
    @objc func onClickMyButton(sender: UIButton) {
        print("send log.")
        ApiClient.instance.sendLog()
        sender.removeFromSuperview()
    }
    
    
    @objc func onUpdate(timer: Timer){
        
        guard UserDataManager.instance.isStart else { return } //初期設定が完了しているときのみ実行
        
        count += 1
        if(count % 5 == 0){ //ファイルに書き込み (５秒に１回)
            count = 0
            
            let now = NSDate()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
            let timeStr = formatter.string(from: now as Date)
            
            //TODO: nilになっていた場合に発生するログデータの欠損はどうする？
            if(myLocationManager.location != nil){
                let str = timeStr + "," + "\(myLocationManager.location?.coordinate.latitude as! Double)" + "," + "\(myLocationManager.location?.coordinate.longitude as! Double)"
                
//                let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last?.appendingPathComponent(UserDataManager.instance.logFileName)
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
            //switch UserDataManager.instance.executionMode {
            switch UserDataManager.instance.group {
            case 1: //自分のみ表示
                if(e.value.type==1 || (e.value.type==0 && e.value.id != uuid)){
                    continue
                }
            case 2: //自分と他人のみ表示
                if(e.value.type == 1){
                    continue
                }
            case 3: //すべて表示
                print("case 3. show all...")
            default:
                print("ERROR!!")
            }
        
            if (evacueeSet.contains(e.key)) {   //すでに表示済みなら座標の変更のみ
                let pin = evacueeHash[e.key]
                let center: CLLocationCoordinate2D = CLLocationCoordinate2DMake(e.value.latitude, e.value.longitude)
                pin?.coordinate = center
                evacueeHash.updateValue(pin!, forKey: e.key)
            }else{
                let pin: MKPointAnnotation = EvacueeMKPointAnnotation(id: e.value.id, type: e.value.type)  //0:人, 1:モノ
                let center: CLLocationCoordinate2D = CLLocationCoordinate2DMake(e.value.latitude, e.value.longitude)
                pin.coordinate = center
                pin.title = e.value.id
                mapView.addAnnotation(pin)
                evacueeSet.insert(e.key)
                evacueeHash.updateValue(pin, forKey: e.key)
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
    
    
    //ピン画像の変更
    //NOTE: mapView.addAnnotation(pin) のときに呼ばれる => pin: MKPointAnnotation(: MKAnnotation)
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        var retAnnotation = MKAnnotationView()
        retAnnotation.annotation = annotation
        
        // 画像を選択.
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

