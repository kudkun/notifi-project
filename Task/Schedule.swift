//
//  Schedule.swift
//  Task
//
//  Created by We on 2018/10/15.
//  Copyright © 2018年 ITユーザー. All rights reserved.
//

import UIKit

class Schedule: UIViewController, UITextViewDelegate{
    var home: Home!
    @IBOutlet var mon: UIButton!
    @IBOutlet var tue: UIButton!
    @IBOutlet var wed: UIButton!
    @IBOutlet var thu: UIButton!
    @IBOutlet var fri: UIButton!
    @IBOutlet var t0: UITextView!
    @IBOutlet var t1: UITextView!
    @IBOutlet var t2: UITextView!
    @IBOutlet var t3: UITextView!
    @IBOutlet var t4: UITextView!
    @IBOutlet var t5: UITextView!
    @IBOutlet var t6: UITextView!
    @IBOutlet var t7: UITextView!
    @IBOutlet var update: UIButton!
    @IBOutlet var result: UITextView!

    @IBAction func update(_ sender: UIButton) {
        if ud.object(forKey: loginToken) == nil{
            viewDidLoad()
            self.result.text = "スケジュールを再取得しました"
            return
        }
        
        let f = Func(flag: .WS, t0: t0!.text , t1: t1!.text, t2: t2!.text, t3: t3!.text, t4: t4!.text, t5: t5!.text, t6: t6!.text, t7: t7!.text, sendWeek: weekDay)
        //文字数エラー表示・空データ排除・データ結合
        var rst: String = f.linking()
        if !rst.isEmpty{
            self.result.text = rst
            return
        }
        
        //スケジュール更新、更新完了or失敗表示（エスケープシーケンス無効化する、DBにアップデート文追加する）
        rst = f.wSchedule()
        if rst.contains("更新完了"){
            let f = Notifi(text: jpWeek + "のスケジュールが更新されました\n確認してください")
            rst = f.judg()
            if !rst.isEmpty{
                self.result.text = rst
                return
            }
            //通知
            rst = f.notifi()
            self.result.text = rst
        }
        viewDidLoad()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.result.isEditable = false
        t0.returnKeyType = UIReturnKeyType.done
        t1.returnKeyType = UIReturnKeyType.done
        t2.returnKeyType = UIReturnKeyType.done
        t3.returnKeyType = UIReturnKeyType.done
        t4.returnKeyType = UIReturnKeyType.done
        t5.returnKeyType = UIReturnKeyType.done
        t6.returnKeyType = UIReturnKeyType.done
        t7.returnKeyType = UIReturnKeyType.done
        t0.delegate = self
        t1.delegate = self
        t2.delegate = self
        t3.delegate = self
        t4.delegate = self
        t5.delegate = self
        t6.delegate = self
        t7.delegate = self
        if ud.object(forKey: loginToken) == nil{
            self.t0.isEditable = false
            self.t1.isEditable = false
            self.t2.isEditable = false
            self.t3.isEditable = false
            self.t4.isEditable = false
            self.t5.isEditable = false
            self.t6.isEditable = false
            self.t7.isEditable = false
        }
        
        
        
        //スケジュール数取得（時間表示用）
//        var tAry: [String] = ["","","","","","","",""]
//        tAry[0] = t0.text
//        tAry[1] = t1.text
//        tAry[2] = t2.text
//        tAry[3] = t3.text
//        tAry[4] = t4.text
//        tAry[5] = t5.text
//        tAry[6] = t6.text
//        tAry[7] = t7.text
//
//        var i = 0
//        var firstSchedule = 0
//        var nullSchedule = 0
//        while i < 8 {
//            if tAry[i] == "" && firstSchedule == 0{
//                firstNull += 1
//            }else if tAry[i] == "" && firstSchedule == 1{
//                nullSchedule += 1
//            }else if tAry[i] != "" {
//                firstSchedule = 1
//                countSchedule += 1
//                countSchedule += nullSchedule
//                nullSchedule = 0
//            }
//            i += 1
//        }
        
        //今日の曜日のボタン押下
        let comp = Calendar.Component.weekday
        let weekdayNo = NSCalendar.current.component(comp, from: NSDate() as Date)
        weekdayButton(weekdayNo: weekdayNo)
    }
    
    //曜日毎のボタン
    @IBAction func mon(_ sender: UIButton) {
        weekdayButton(weekdayNo: 2)
    }
    @IBAction func tue(_ sender: UIButton) {
        weekdayButton(weekdayNo: 3)
    }
    @IBAction func wed(_ sender: UIButton) {
        weekdayButton(weekdayNo: 4)
    }
    @IBAction func thu(_ sender: UIButton) {
        weekdayButton(weekdayNo: 5)
    }
    @IBAction func fri(_ sender: UIButton) {
        weekdayButton(weekdayNo: 6)
    }
    
    //各曜日のスケジュールを表示（現在は月曜日のみ対応）
    func weekdayButton(weekdayNo: Int) {
        let weekdayAry: [String] = ["","","mon","tue","wed","thu","fri",""]
        weekDay = weekdayAry[weekdayNo]
        if weekDay.isEmpty{
            self.result.text = "今日は休日です"
            return
        }
        
        //全フォントサイズ20
        fontSize20()
        //指定したボタンサイズ35
        fontSize35(weekday: weekDay)
        
        //グループ作成者が登録したスケジュールを取得（のちにweekday変数をコンストラクタで処理させる）
        let rst: String = Func(flag: .RS, setWeek: weekDay).rSchedule()
        let tAry = rst.components(separatedBy: ",")
        t0.text = tAry[0]
        t1.text = tAry[1]
        t2.text = tAry[2]
        t3.text = tAry[3]
        t4.text = tAry[4]
        t5.text = tAry[5]
        t6.text = tAry[6]
        t7.text = tAry[7]
    }
    
    func fontSize35(weekday: String){
        switch weekday {
        case "mon":
            mon.titleLabel?.font = UIFont.systemFont(ofSize: 35)
            jpWeek = "月曜日"
        case "tue":
            tue.titleLabel?.font = UIFont.systemFont(ofSize: 35)
            jpWeek = "火曜日"
        case "wed":
            wed.titleLabel?.font = UIFont.systemFont(ofSize: 35)
            jpWeek = "水曜日"
        case "thu":
            thu.titleLabel?.font = UIFont.systemFont(ofSize: 35)
            jpWeek = "木曜日"
        case "fri":
            fri.titleLabel?.font = UIFont.systemFont(ofSize: 35)
            jpWeek = "金曜日"
        default:
            fontSize20()
        }
    }
    
    func fontSize20(){
        mon.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        tue.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        wed.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        thu.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        fri.titleLabel?.font = UIFont.systemFont(ofSize: 20)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" || text == "," {
            t0.resignFirstResponder()
            t1.resignFirstResponder()
            t2.resignFirstResponder()
            t3.resignFirstResponder()
            t4.resignFirstResponder()
            t5.resignFirstResponder()
            t6.resignFirstResponder()
            t7.resignFirstResponder()
            return false
        }
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
