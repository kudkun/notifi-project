//
//  Home.swift
//  Task
//
//  Created by We on 2018/09/30.
//  Copyright © 2018年 We. All rights reserved.
//

import UIKit

class Home: UIViewController, UITextViewDelegate{
    @IBOutlet var tableNotifi: UITableView!
    @IBOutlet var nowSubject: UITextView!
    @IBOutlet var nextSubject: UITextView!
    @IBOutlet var notifi: UIButton!
    @IBOutlet var logout: UIButton!
    @IBOutlet var result: UITextView!
    @IBOutlet var notifiText: UITextView!
    @IBOutlet var tokenCopy: UIButton!
    @IBOutlet var friend: UIButton!
    @IBOutlet var today: UILabel!
    
    @IBAction func notifi(_ sender: UIButton) {
        var startTime: String = ""
        switch firstNull {
        case 0:
            startTime = "9:00"
        case 1:
            startTime = "9:45"
        case 2:
            startTime = "10:40"
        case 3:
            startTime = "11:25"
        case 4:
            startTime = "13:00"
        case 5:
            startTime = "13:45"
        case 6:
            startTime = "14:40"
        default:
            startTime = "15:25"
        }
        
        let sumSchedule = countSchedule + firstNull
        switch sumSchedule {
        case 1:
            self.today.text = "今日は" + startTime + "〜9:45"
        case 2:
            self.today.text = "今日は" + startTime + "〜10:30"
        case 3:
            self.today.text = "今日は" + startTime + "〜11:25"
        case 4:
            self.today.text = "今日は" + startTime + "〜12:10"
        case 5:
            self.today.text = "今日は" + startTime + "〜13:45"
        case 6:
            self.today.text = "今日は" + startTime + "〜14:30"
        case 7:
            self.today.text = "今日は" + startTime + "〜15:25"
        default:
            self.today.text = "スケジュールを確認しましょう"
        }
        
        if ud.object(forKey: loginToken) == nil{
            viewDidLoad()
            self.result.text = "掲示板を再取得しました"
            return
        }
        
        //管理者による更新か検証
        let f = Func(text: notifiText.text!, flag: .WB)
        var rst: String = f.notifiJudg()
        if !rst.isEmpty{
            self.result.text = rst
            return
        }
        
        //掲示板更新
        rst = f.wBulletin()
        if !rst.contains("更新完了"){
            return
        }
        
        let ff = Notifi(text: notifiText.text!)
        //通知内容等のエラー検証
        rst = ff.judg()
        if !rst.isEmpty{
            self.result.text = rst
            return
        }
        
        //Line通知、通知完了or失敗表示
        rst = ff.notifi()
        self.result.text = rst
        
        viewDidLoad()
    }
    
    @IBAction func logout(_ sender: UIButton) {
        //保持データを色々と破棄
        if ud.object(forKey: loginToken) != nil {
            ud.removeObject(forKey: loginToken)
        }
        if ud.object(forKey: group) != nil{
            ud.removeObject(forKey: group)
        }
        
        //最初の画面に遷移
        let storyboard: UIStoryboard = self.storyboard!
        let first = storyboard.instantiateViewController(withIdentifier: "first")
        self.present(first,animated: true,completion: nil)
    }
    
    //Lineアカウント追加ページ遷移
    @IBAction func friend(_ sender: UIButton) {
        if ud.object(forKey: friendUrl) == nil{
            self.result.text = "アカウントが登録されていません"
            return
        }
        let urlStr: String = ud.object(forKey: friendUrl) as! String
        let url = URL(string: "https://line.me/R/ti/p/" + urlStr)
        if UIApplication.shared.canOpenURL(url!){
            UIApplication.shared.open(url!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
        }else{
            self.result.text = "アカウントのURLが間違っています\nグループ作成者に問い合わせてください"
        }
    }
    
    //アクセストークンをクリップボードにコピー
    @IBAction func tokenCopy(_ sender: UIButton) {
        if ud.object(forKey: accessToken) != nil{
            let board = UIPasteboard.general
            board.string = ud.object(forKey: accessToken) as? String
        }else{
            self.result.text = "アクセストークンが登録されていません"
        }
    }
    
    func today(str: String){
        self.today.text = str
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //掲示板表示
        var rst: String = Func(flag: .RB).rBulletin()
        if !rst.contains(serverError){
            self.notifiText.text = rst
        }
        
        //今の科目、次の科目表示（現在は月曜日のみ対応）
        rst = Func(flag: .NOW).nowSub()
        if !rst.contains(serverError){
            self.nowSubject.text = rst
        }

        rst = Func(flag: .NEXT).nextSub()
        if !rst.contains(serverError){
            self.nextSubject.text = rst
        }
        
        self.result.isEditable = false
        self.nowSubject.isEditable = false
        self.nextSubject.isEditable = false
        notifiText.returnKeyType = UIReturnKeyType.done
        notifiText.delegate = self
        if ud.object(forKey: loginToken) == nil{
            self.notifiText.isEditable = false
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            notifiText.resignFirstResponder()
            return false
        }
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
