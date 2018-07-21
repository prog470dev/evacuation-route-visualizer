//
//  SettingViewController.swift
//  EvacuationRouteVisualizer
//
//  Created by 清水大樹 on 2018/07/07.
//  Copyright © 2018 prog470dev. All rights reserved.
//

import UIKit

enum ButtonCategory {
    case TYPE
    case GROUP
    case AGE
    case SEX
    case OK
}

class SettingViewController: UIViewController {

    var typeButtons: [SettingUIButton] = []
    var groupButtons: [SettingUIButton] = []
    var ageButtons: [SettingUIButton] = []
    var sexButtons: [SettingUIButton] = []
    var okButton: SettingUIButton!

    /* 押下で設定されるボタンの値 */
    var typeValues: [TypeValue] = [.HUMAN, .OBJECT]
    var groupValues: [GroupValue] = [.ONE, .TWO, .THREE]
    var ageValues: [AgeValue] = [.GENERATION_10, .GENERATION_20, .GENERATION_30, .GENERATION_40, .GENERATION_50, .GENERATION_60, .GENERATION_70, .GENERATION_80]
    var sexValues: [SexValue] = [.MALE, .FEMALE]

    /* ボタンの表示テキスト */
    var typeTexts: [String] = ["人", "物"]
    var groupTexts: [String] = ["1:自", "2:自他", "3:自他物"]
    var ageTexts: [String] = ["10代", "20代", "30代", "40代", "50代", "60代", "70代", "80代~"]
    var sexTexts: [String] = ["男", "女"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .white
        createButtons(parentView: self.view)
        
        UserDataManager.instance.startGettingLocation()  //このタイミングで位置情報取得を開始しないと落ちる
        
        ApiClient.instance.getShelterInfo() //避難所データの取得
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //TODO: テキスト挿入
    func createButtons(parentView: UIView){
        /* TYPE */
        for i in 0..<typeValues.count {
            typeButtons.append(SettingUIButton(frame: CGRect(), category: .TYPE, data: typeValues[i].rawValue))
            typeButtons[i].backgroundColor = .orange
            typeButtons[i].translatesAutoresizingMaskIntoConstraints = false
            typeButtons[i].setTitle(typeTexts[i], for: .normal)
            parentView.addSubview(typeButtons[i])
            
            typeButtons[i].addTarget(self, action: #selector(SettingViewController.onClickButton(sender:)), for: .touchUpInside)
        }
        //Auto Layoutによる配置
        for i in 0..<typeValues.count {
            if(i == 0){
                typeButtons[i].leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: 10.0).isActive = true  //左端
                typeButtons[i].topAnchor.constraint(equalTo: parentView.topAnchor, constant: 50.0).isActive = true  //上端
                typeButtons[i].widthAnchor.constraint(equalTo: parentView.widthAnchor, multiplier: 0.20).isActive = true    //幅
                typeButtons[i].heightAnchor.constraint(equalToConstant: 40.0).isActive = true   //高さ
            }else{
                //１つ目に合わせる
                typeButtons[i].leadingAnchor.constraint(equalTo: typeButtons[i-1].trailingAnchor, constant: 10.0).isActive = true
                typeButtons[i].topAnchor.constraint(equalTo: typeButtons[i-1].topAnchor).isActive = true
                typeButtons[i].widthAnchor.constraint(equalTo: typeButtons[i-1].widthAnchor).isActive = true
                typeButtons[i].heightAnchor.constraint(equalTo: typeButtons[i-1].heightAnchor).isActive = true
            }
        }
        let _ = createTitle(text: "タイプ", parentView: typeButtons[0])
        
        /* GROUP */
        for i in 0..<groupValues.count {
            groupButtons.append(SettingUIButton(frame: CGRect(), category: .GROUP, data: groupValues[i].rawValue))
            groupButtons[i].backgroundColor = .orange
            groupButtons[i].translatesAutoresizingMaskIntoConstraints = false
            groupButtons[i].setTitle(groupTexts[i], for: .normal)
            groupButtons[i].titleLabel?.font = UIFont.systemFont(ofSize: 15)    //このボタンだけ文字数が多いため
            parentView.addSubview(groupButtons[i])
            
            groupButtons[i].addTarget(self, action: #selector(SettingViewController.onClickButton(sender:)), for: .touchUpInside)
        }
        for i in 0..<groupValues.count {
            if(i == 0){
                groupButtons[i].leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: 10.0).isActive = true  //左端
                groupButtons[i].topAnchor.constraint(equalTo: typeButtons[typeButtons.count-1].bottomAnchor, constant: 50.0).isActive = true  //上端
                groupButtons[i].widthAnchor.constraint(equalTo: parentView.widthAnchor, multiplier: 0.20).isActive = true    //幅
                groupButtons[i].heightAnchor.constraint(equalToConstant: 40.0).isActive = true   //高さ
            }else{
                groupButtons[i].leadingAnchor.constraint(equalTo: groupButtons[i-1].trailingAnchor, constant: 10.0).isActive = true
                groupButtons[i].topAnchor.constraint(equalTo: groupButtons[i-1].topAnchor).isActive = true
                groupButtons[i].widthAnchor.constraint(equalTo: groupButtons[i-1].widthAnchor).isActive = true
                groupButtons[i].heightAnchor.constraint(equalTo: typeButtons[i-1].heightAnchor).isActive = true
            }
        }
        let _ = createTitle(text: "グループ", parentView: groupButtons[0])
        
        /* AGE */
        for i in 0..<ageValues.count {
            ageButtons.append(SettingUIButton(frame: CGRect(), category: .AGE, data: ageValues[i].rawValue))
            ageButtons[i].backgroundColor = .orange
            ageButtons[i].translatesAutoresizingMaskIntoConstraints = false
            ageButtons[i].setTitle(ageTexts[i], for: .normal)
            parentView.addSubview(ageButtons[i])
            
            ageButtons[i].addTarget(self, action: #selector(SettingViewController.onClickButton(sender:)), for: .touchUpInside)
        }
        for i in 0..<ageValues.count {
            if(i == 0){
                ageButtons[i].leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: 10.0).isActive = true  //左端
                ageButtons[i].topAnchor.constraint(equalTo: groupButtons[groupButtons.count-1].bottomAnchor, constant: 50.0).isActive = true  //上端
                ageButtons[i].widthAnchor.constraint(equalTo: parentView.widthAnchor, multiplier: 0.20).isActive = true    //幅
                ageButtons[i].heightAnchor.constraint(equalToConstant: 40.0).isActive = true   //高さ
            } else if i == 4 {
                ageButtons[i].leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: 10.0).isActive = true
                ageButtons[i].topAnchor.constraint(equalTo: ageButtons[0].bottomAnchor, constant: 5.0).isActive = true
                ageButtons[i].widthAnchor.constraint(equalTo: parentView.widthAnchor, multiplier: 0.20).isActive = true
                ageButtons[i].heightAnchor.constraint(equalToConstant: 40.0).isActive = true
            }else if i < 4{    //１段目
                ageButtons[i].leadingAnchor.constraint(equalTo: ageButtons[i-1].trailingAnchor, constant: 10.0).isActive = true
                ageButtons[i].topAnchor.constraint(equalTo: ageButtons[i-1].topAnchor).isActive = true
                ageButtons[i].widthAnchor.constraint(equalTo: ageButtons[i-1].widthAnchor).isActive = true
                ageButtons[i].heightAnchor.constraint(equalTo: groupButtons[i-1].heightAnchor).isActive = true
            } else {    //２段目
                ageButtons[i].leadingAnchor.constraint(equalTo: ageButtons[i-1].trailingAnchor, constant: 10.0).isActive = true
                ageButtons[i].topAnchor.constraint(equalTo: ageButtons[i-1].topAnchor).isActive = true
                ageButtons[i].widthAnchor.constraint(equalTo: parentView.widthAnchor, multiplier: 0.20).isActive = true
                ageButtons[i].heightAnchor.constraint(equalToConstant: 40.0).isActive = true
            }
        }
        let _ = createTitle(text: "年代", parentView: ageButtons[0])
        
        /* SEX */
        for i in 0..<sexValues.count {
            sexButtons.append(SettingUIButton(frame: CGRect(), category: .SEX, data: sexValues[i].rawValue))
            sexButtons[i].backgroundColor = .orange
            sexButtons[i].translatesAutoresizingMaskIntoConstraints = false
            sexButtons[i].setTitle(sexTexts[i], for: .normal)
            parentView.addSubview(sexButtons[i])
            
            sexButtons[i].addTarget(self, action: #selector(SettingViewController.onClickButton(sender:)), for: .touchUpInside)
        }
        for i in 0..<sexValues.count {
            if(i == 0){
                sexButtons[i].leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: 10.0).isActive = true  //左端
                sexButtons[i].topAnchor.constraint(equalTo: ageButtons[ageButtons.count-1].bottomAnchor, constant: 50.0).isActive = true  //上端
                sexButtons[i].widthAnchor.constraint(equalTo: parentView.widthAnchor, multiplier: 0.20).isActive = true    //幅
                sexButtons[i].heightAnchor.constraint(equalToConstant: 40.0).isActive = true   //高さ
            }else{
                sexButtons[i].leadingAnchor.constraint(equalTo: sexButtons[i-1].trailingAnchor, constant: 10.0).isActive = true
                sexButtons[i].topAnchor.constraint(equalTo: sexButtons[i-1].topAnchor).isActive = true
                sexButtons[i].widthAnchor.constraint(equalTo: sexButtons[i-1].widthAnchor).isActive = true
                sexButtons[i].heightAnchor.constraint(equalTo: ageButtons[i-1].heightAnchor).isActive = true
            }
        }
        let _ = createTitle(text: "性別", parentView: sexButtons[0])
        
        /* OKボタン */
        okButton = SettingUIButton(frame: CGRect(), category: ButtonCategory.OK, data: 1)
        okButton.backgroundColor = .blue
        okButton.translatesAutoresizingMaskIntoConstraints = false
        okButton.setTitle("OK", for: .normal)
        parentView.addSubview(okButton)
        okButton.addTarget(self, action: #selector(SettingViewController.onClickButton(sender:)), for: .touchUpInside)
        okButton.leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: 10.0).isActive = true  //左端
        okButton.topAnchor.constraint(equalTo: sexButtons[sexButtons.count-1].bottomAnchor, constant: 50.0).isActive = true  //上端
        okButton.widthAnchor.constraint(equalTo: parentView.widthAnchor, multiplier: 0.20).isActive = true    //幅
        okButton.heightAnchor.constraint(equalToConstant: 40.0).isActive = true   //高さ
    }
    
    func createTitle(text: String, parentView: UIView) -> UILabel {
        let label: UILabel = UILabel(frame: CGRect())
        
        label.textColor = UIColor.black
        label.text = text
        label.font = UIFont.systemFont(ofSize: 15)
        label.textAlignment = NSTextAlignment.left
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        parentView.superview?.addSubview(label)
        
        label.leadingAnchor.constraint(equalTo: parentView.leadingAnchor).isActive = true  //左端
        label.bottomAnchor.constraint(equalTo: parentView.topAnchor, constant: -5.0).isActive = true  //上端
        label.widthAnchor.constraint(equalToConstant: 150.0).isActive = true
        label.heightAnchor.constraint(equalToConstant: 20.0).isActive = true   //高さ
        
        return label
    }
    
    @objc func onClickButton(sender: SettingUIButton){
        
        let category = sender.category
        let data = sender.data
        
        guard category != nil && data != nil else {
            return  //error
        }

        switch category! {
        case .TYPE:
            UserDataManager.instance.type = sender.data
            for e in typeButtons {
                e.backgroundColor = .orange
            }
        case .GROUP:
            UserDataManager.instance.group = sender.data
            for e in groupButtons {
                e.backgroundColor = .orange
            }
        case .AGE:
            UserDataManager.instance.age = sender.data
            for e in ageButtons {
                e.backgroundColor = .orange
            }
        case .SEX:
            UserDataManager.instance.sex = sender.data
            for e in sexButtons {
                e.backgroundColor = .orange
            }
        case .OK:
            /* データの登録 */
            if(UserDataManager.instance.type == -1 || UserDataManager.instance.group == -1 ||
               UserDataManager.instance.age == -1 || UserDataManager.instance.sex == -1){
                print("there are some missing value...")
            } else if(UserDataManager.instance.shelterLatitude > 500.0 || UserDataManager.instance.shelterLatitude > 500.0){
                ApiClient.instance.getShelterInfo()
                print("there are some missing shelter...")
            }else{
                UserDataManager.instance.isStart = true
                UserDataManager.instance.createLog(fileName: UserDataManager.instance.getLogFileName()) //ログファイル生成
                let viewController: UIViewController = ViewController()
                self.present(viewController, animated: false, completion: nil)
            }
        default:
            print("error")
        }
        
        if(category != .OK){
            sender.backgroundColor = .red
        }
        
    }

}

class SettingUIButton: UIButton{
    var category: ButtonCategory!
    var data: Int!
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(frame:CGRect, category: ButtonCategory, data: Int){
        super.init(frame: frame)
        
        self.category = category
        self.data = data
    }
}
