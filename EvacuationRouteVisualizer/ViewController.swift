//
//  ViewController.swift
//  EvacuationRouteVisualizer
//
//  Created by 清水大樹 on 2018/05/18.
//  Copyright © 2018 prog470dev. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {

    var mapView: MKMapView!
    
    var evacueeSet: Set<String> = []    //同じピンを複数登録しないために設定するが、ハッシュマップだけでやりたい
    var evacueeHash: [String:MKPointAnnotation] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MapViewの生成.
        mapView = MKMapView()
        mapView.frame = self.view.bounds
        mapView.delegate = self
        self.view.addSubview(mapView)
        
        // 中心点の緯度経度.
        let myLat: CLLocationDegrees = 37.506804
        let myLon: CLLocationDegrees = 139.930531
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
        
    }
    
    @objc func onUpdate(timer: Timer){
        
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
                
                if(e.key == "100"){ //自分はスキップ
                    continue
                }
                //メンバー追加の通知
                let label: UILabel = UILabel(frame: CGRect(x: 0, y: self.view.frame.size.height - 50, width: 200, height: 50))
                label.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1) //UIColor.orange
                label.layer.masksToBounds = true
                label.layer.cornerRadius = 20.0
                label.textColor = UIColor.white
                label.text = "JOIN: " + e.value.id
                label.textAlignment = NSTextAlignment.center
                self.view.addSubview(label)
                
                //アニメーション
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

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        print("regionDidChangeAnimated")
    }
    
    //ピン画像の変更
    //NOTE: mapView.addAnnotation(pin) のときに呼ばれる => pin: MKPointAnnotation(: MKAnnotation)
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        var retAnnotation = MKAnnotationView()
        retAnnotation.annotation = annotation
        
        // 画像を選択.
        if let e = annotation as? EvacueeMKPointAnnotation{
            if(e.id == "100"){  //自分を判定（実際にはUUID）
                retAnnotation.image = UIImage(named: "annotation")!
            }else{
                retAnnotation.image = UIImage(named: "annotation_other")!
            }
            retAnnotation.annotation = annotation
        }
        
        return  retAnnotation
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

