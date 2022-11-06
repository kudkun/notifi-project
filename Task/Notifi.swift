//
//  Notifi.swift
//  Task
//
//  Created by We on 2018/10/12.
//  Copyright © 2018年 ITユーザー. All rights reserved.
//

import Foundation

class Notifi{
    var text: String = ""
    
    //通知内容
    init(text: String){
        self.text = text
    }
    
    //通知エラー
    func judg() -> String{
        var errorText: String = ""
        if ud.object(forKey: "accessToken") == nil {
            errorText = "更新しました\nアクセストークンを設定して通知できます"
            return errorText
        }
        return ""
    }
    
    //Line通知
    func notifi() -> String{
        var reply: String = ""
        let token: String = ud.object(forKey: "accessToken") as! String
        let postData: String = "text=" + text + "&token=" + token
        var request = URLRequest(url: URL(string: "https://kudkun.com/schedule/notifi.php")!)
        request.httpMethod = "POST"
        request.httpBody = postData.data(using: .utf8)
        let session = URLSession.shared.dataTask(with: request,completionHandler: { (data, response, error) in
            if data == nil || error != nil{
                reply = serverError
                return
            }
            //通知完了or通知失敗
            reply = String(data: data!,encoding: .utf8)!
        })
        session.resume()
        Thread.sleep(forTimeInterval: 1)
        return reply
    }
}
