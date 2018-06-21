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
    
    let uuid = UIDevice.current.identifierForVendor!.uuidString
    
    var count = 0 //自分の座標登録の回数を制限するため
    
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
        Timer.scheduledTimer(timeInterval: 0.2,
                             target: self,
                             selector: #selector(ViewController.onUpdate(timer:)),
                             userInfo: nil,
                             repeats: true)
        
        //自分の登録
        //let center: CLLocationCoordinate2D = CLLocationCoordinate2DMake(myLat, myLon)   //TODO: 自分の現在地を登録
        ApiClient.instance.registEvacuee(id: uuid, coordinate: (myLocationManager.location?.coordinate)!)
    }
    
    @objc func onUpdate(timer: Timer){
        //自分の登録
        count += 1
        if(count % 5 == 0){
            ApiClient.instance.registEvacuee(id: uuid, coordinate: (myLocationManager.location?.coordinate)!)
            count = 0
        }
        
        //for var e in DataCliant.instance.evacuees {
        for var e in ApiClient.instance.evacuees {
            
            if (evacueeSet.contains(e.key)) {
                let pin = evacueeHash[e.key]
                let center: CLLocationCoordinate2D = CLLocationCoordinate2DMake(e.value.latitude, e.value.longitude)
                pin?.coordinate = center
                evacueeHash.updateValue(pin!, forKey: e.key)
            }else{
                let pin: MKPointAnnotation = EvacueeMKPointAnnotation(id: e.value.id)
                let center: CLLocationCoordinate2D = CLLocationCoordinate2DMake(e.value.latitude, e.value.longitude)
                pin.coordinate = center
                pin.title = e.value.id
                mapView.addAnnotation(pin)
                evacueeSet.insert(e.key)
                evacueeHash.updateValue(pin, forKey: e.key)
                
                if(e.key == uuid){ //自分はスキップ
                    continue
                }
                
                //メンバー追加の通知表示
                let label: UILabel = UILabel(frame: CGRect(x: 0, y: self.view.frame.size.height - 50, width: 200, height: 50))
                label.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1) //UIColor.orange
                label.layer.masksToBounds = true
                label.layer.cornerRadius = 20.0
                label.textColor = UIColor.white
                label.text = "JOIN: " + e.value.id
                label.textAlignment = NSTextAlignment.center
                self.view.addSubview(label)
                label.alpha = 0.0
                UIView.animate(withDuration: 0.5, delay: 0.0, options: [.curveEaseIn], animations: {
                    label.alpha = 1.0
                }, completion:{ _ in
                    UIView.animate(withDuration: 0.5, delay: 0.5, options: [.curveEaseIn], animations: {
                        label.alpha = 0.0
                    }, completion:{ _ in
                      label.removeFromSuperview()
                    })
                })
                
            }
        }
        
    }

    
    // GPSから値を取得した際に呼び出されるメソッド.
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//
//        print("didUpdateLocations")
//
//        // 配列から現在座標を取得.
//        let myLocations: NSArray = locations as NSArray
//        let myLastLocation: CLLocation = myLocations.lastObject as! CLLocation
//        let myLocation: CLLocationCoordinate2D = myLastLocation.coordinate
//
//        print("\(myLocation.latitude), \(myLocation.longitude)")
//        //現在地表示
//        let label: UILabel = UILabel(frame: CGRect(x: 0, y: self.view.frame.size.height - 50, width: 200, height: 50))
//        label.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1) //UIColor.orange
//        label.layer.masksToBounds = true
//        label.layer.cornerRadius = 20.0
//        label.textColor = UIColor.white
//        label.text = "\(myLocation.latitude)" + ", " + "\(myLocation.longitude)"
//        label.textAlignment = NSTextAlignment.center
//        self.view.addSubview(label)
//        label.alpha = 0.0
//        UIView.animate(withDuration: 0.5, delay: 0.0, options: [.curveEaseIn], animations: {
//            label.alpha = 1.0
//        }, completion:{ _ in
//            UIView.animate(withDuration: 0.5, delay: 0.5, options: [.curveEaseIn], animations: {
//                label.alpha = 0.0
//            }, completion:{ _ in
//                label.removeFromSuperview()
//            })
//        })
//        //
//
//        //現在地の登録
//        ApiClient.instance.registEvacuee(id: uuid, coordinate: myLocation)
//    }
    
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
            if(e.id == uuid){  //自分を判定（実際にはUUID）
                retAnnotation.image = UIImage(named: "annotation")!
                (annotation as? EvacueeMKPointAnnotation)?.id = e.id    //タップ時のタイトル表示
                (annotation as? EvacueeMKPointAnnotation)?.title = e.id
            }else{
                retAnnotation.image = UIImage(named: "annotation_other")!
                (annotation as? EvacueeMKPointAnnotation)?.id = e.id
                (annotation as? EvacueeMKPointAnnotation)?.title = e.id
            }
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

