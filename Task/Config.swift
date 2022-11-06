//
//  Config.swift
//  Task
//
//  Created by We on 2018/10/11.
//  Copyright © 2018年 ITユーザー. All rights reserved.
//

import UIKit

class Config: UIViewController, UITextFieldDelegate{
    @IBOutlet var register: UIButton!
    @IBOutlet var change: UIButton!
    @IBOutlet var token: UITextField!
    @IBOutlet var url: UITextField!
    @IBOutlet var developerUrl: UIButton!
    @IBOutlet var result: UITextView!
    
    //アクセストークン・URL登録
    @IBAction func register(_ sender: UIButton) {
        if token.text == "" || url.text == ""{
            self.result.text = "アカウントURLとアクセストークンの両方が必要です"
            return
        }
        ud.set(token.text!, forKey: accessToken)
        ud.set(url.text!, forKey: friendUrl)
        ud.synchronize()
        notNull()
    }
    
    //アクセストークン・URL削除
    @IBAction func change(_ sender: UIButton) {
        if ud.object(forKey: accessToken) != nil {
            ud.removeObject(forKey: accessToken)
        }
        if ud.object(forKey: friendUrl) != nil{
            ud.removeObject(forKey: friendUrl)
        }
        null()
    }
    
    //アクセストークン・URLを登録禁止、変更許可
    func notNull(){
        self.register.isEnabled = false
        self.change.isEnabled = true
        self.token.isEnabled = false
        self.token.text = ud.object(forKey: accessToken) as? String
        self.url.isEnabled = false
        self.url.text = ud.object(forKey: friendUrl) as? String
    }
    //〃を登録許可、変更禁止
    func null(){
        self.register.isEnabled = true
        self.change.isEnabled = false
        self.token.isEnabled = true
        self.url.isEnabled = true
    }
    //〃を登録禁止、変更禁止
    func disable(){
        self.register.isEnabled = false
        self.change.isEnabled = false
        self.token.isEnabled = false
        self.url.isEnabled = false
    }
    
    //アカウント作成サイト
    @IBAction func developerUrl(_ sender: UIButton) {
        let url = URL(string: "https://developers.line.me/")
        if UIApplication.shared.canOpenURL(url!){
            UIApplication.shared.open(url!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
        }else{
            self.result.text = "リンク先がありません"
        }
    }
    
    //登録、更新の可否設定
    override func viewDidLoad() {
        super.viewDidLoad()
        self.result.isEditable = false
        
        if ud.object(forKey: loginToken) == nil{
            disable()
        }else{
            if ud.object(forKey: accessToken) != nil || ud.object(forKey: friendUrl) != nil{
                notNull()
            }else{
                null()
            }
        }
        
        token.returnKeyType = UIReturnKeyType.done
        url.returnKeyType = UIReturnKeyType.done
        token.delegate = self
        url.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        token.resignFirstResponder()
        url.resignFirstResponder()
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
