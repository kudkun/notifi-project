//
//  ViewController.swift
//  Task
//
//  Created by We on 2018/09/03.
//  Copyright © 2018年 We. All rights reserved.
//
//
//～未実装～
//アカウント登録時のメールアドレス認証
//アカウント登録後のログイン遷移
//データベースハッシュ化文字数設定
//スケジュール表に紐づけた1限目開始時間と最終時限終了時間の表示ß
//パスワード変更
//コードの保守性が低い、冗長性がある
//偽ポストデータ送信で掲示板、スケジュールのデータ更新可能
//アカウント削除時に関連テーブル削除

import UIKit

//UserDefaults用変数
let loginToken: String = "loginToken"
let accessToken: String = "accessToken"
let group: String = "groupName"
let friendUrl: String = "friendUrl"
let ud = UserDefaults.standard

//グループ名
var groupName: String? = ""
var serverError: String = "サーバーへの接続に失敗"

//曜日用変数
var weekDay: String = ""
var jpWeek: String = ""

//今日の授業時間合計
var countSchedule = 0
var firstNull = 0
//ピッカービュー
var dataList: [String] = []

class ViewController: UIViewController, UITextFieldDelegate{
    @IBOutlet var login: UIButton!
    @IBOutlet var email: UITextField!
    @IBOutlet var password: UITextField!
    @IBOutlet var result: UITextView!
    @IBOutlet var register: UIButton!
    @IBOutlet var kill: UIButton!
    @IBOutlet var picker: UIPickerView!
    @IBOutlet var join: UIButton!
    
    @IBAction func login(_ sender: UIButton){
        let f = Func(email: email.text!, password: password.text!, flag: .LOGIN)
        //メアド等の検証
        var rst: String = f.judg()
        if !rst.isEmpty{
            self.result.text = rst
            return
        }
        
        //ログイン
        rst = f.login()
        
        //ログイントークンを取得できれば画面遷移orエラー表示
        if ud.object(forKey: loginToken) != nil && ud.object(forKey: group) != nil{
            let storyboard: UIStoryboard = self.storyboard!
            let tab = storyboard.instantiateViewController(withIdentifier: "tab")
            self.present(tab,animated: true,completion: nil)
        }else{
            self.result.text = rst
        }
    }
    
    //グループ名が存在すれば画面遷移
    @IBAction func join(_ sender: UIButton) {
        if dataList.count > 0 {
            groupName = dataList[picker.selectedRow(inComponent: 0)]
        }
        
        if groupName!.isEmpty || groupName!.contains("グループはありません"){
            self.result.text = "グループはありません"
            return
        }else if groupName!.contains(serverError){
            self.result.text = serverError
            return
        }
        if ud.object(forKey: loginToken) != nil{
            viewDidLoad()
            return
        }
        
        ud.set(groupName!, forKey: group)
        ud.synchronize()
        let storyboard: UIStoryboard = self.storyboard!
        let tab = storyboard.instantiateViewController(withIdentifier: "tab")
        self.present(tab,animated: true,completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let f = Func(flag: .GROUPNAME)
        //グループ一覧表示
        let rst: String = f.getGroup()
        let rstAry: [String] = rst.components(separatedBy: "\n")
        if !rstAry.isEmpty{
            dataList = rstAry
            dataList.removeFirst()
            pickerSetting()
        }
        
        //以下UIデザイン（一つのクラスで全Controllerに適用させる処理に変更する）
        //エラーフォーム書き込み禁止
        self.result.isEditable = false
        
        email.returnKeyType = UIReturnKeyType.done
        password.returnKeyType = UIReturnKeyType.done
        email.delegate = self
        password.delegate = self
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //アプリ起動時セッション維持
        if ud.object(forKey: loginToken) != nil && ud.object(forKey: group) != nil{
            let token: String = ud.object(forKey: loginToken) as! String
            let f = Func(token: token, flag: .SESSION)
            //ログイントークン取得
            let rst: String = f.session()
            //保持しているログイントークンが結果と一致で遷移、一致しない場合ログイントークン削除
            if rst.contains(token){
                let storyboard: UIStoryboard = self.storyboard!
                let tab = storyboard.instantiateViewController(withIdentifier: "tab")
                self.present(tab,animated: true,completion: nil)
            }else{
                ud.removeObject(forKey: loginToken)
            }
        }else if ud.object(forKey: group) != nil{
            let storyboard: UIStoryboard = self.storyboard!
            let tab = storyboard.instantiateViewController(withIdentifier: "tab")
            self.present(tab,animated: true,completion: nil)
        }else{
            viewDidLoad()
        }
        //グループ再取得
//        groupName = dataList[picker.selectedRow(inComponent: 0)]
//        if groupName!.isEmpty{
//            viewDidLoad()
//        }
    }
    
    //ピッカービュー設定
    func pickerSetting(){
        picker.delegate = self
        picker.dataSource = self
        picker.showsSelectionIndicator = true;
//        picker.selectRow(0, inComponent: 0, animated: true)
        self.view.addSubview(picker)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        email.resignFirstResponder()
        password.resignFirstResponder()
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

//ピッカービュー設定
extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource{
    //表示する列数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    //データ表示個数
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataList.count
    }
    //表示する文字列
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return dataList[row]
    }
    //選択時の処理
//    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//    }
}
