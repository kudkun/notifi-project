//
//  Func.swift
//  Task
//
//  Created by We on 2018/10/09.
//  Copyright © 2018年 ITユーザー. All rights reserved.
//

import Foundation

enum Flag{
case LOGIN, REGISTER, KILL, SESSION, GROUPNAME, WS, RS, WB, RB, NOW, NEXT
    func flagName() -> String{
        switch self{
        case .LOGIN:
            return "login"
        case .REGISTER:
            return "register"
        case .KILL:
            return "kill"
        case .SESSION:
            return "session"
        case .GROUPNAME:
            return "groupName"
        case .WS:
            return "wSchedule"
        case .RS:
            return "rSchedule"
        case .WB:
            return "wBulletin"
        case .RB:
            return "rBulletin"
        case .NOW:
            return "nowSub"
        case .NEXT:
            return "nextSub"
        }
    }
}

class Func{
    var email: String = ""
    var password: String = ""
    var again: String = ""
    var flag: Flag
    var groupName: String = ""
    var token: String = ""
    var tLink: String = ""
    var text: String = ""
    var weekDay: String = ""
    var t = [String](repeating: "", count: 8)
    
    //セッション維持
    init(token: String, flag: Flag){
        self.token = token
        self.flag = flag
    }
    //掲示板更新
    init(text: String, flag: Flag){
        //ログイントークンは不正更新対策
        self.token = ud.object(forKey: loginToken) as! String
        self.groupName = ud.object(forKey: group) as! String
        self.text = text
        self.flag = flag
    }
    //掲示板読み込み、グループ名取得、今の科目・次の科目
    init(flag: Flag){
        if ud.object(forKey: group) != nil{
            self.groupName = ud.object(forKey: group) as! String
        }
        self.flag = flag
    }
    //スケジュール読み込み
    init(flag: Flag, setWeek: String){
        self.groupName = ud.object(forKey: group) as! String
        self.flag = flag
        self.weekDay = setWeek
    }
    //スケジュール更新
    init(flag: Flag, t0: String, t1: String, t2: String, t3: String, t4: String, t5: String, t6: String, t7: String, sendWeek: String){
        //ログイントークンは不正更新対策
        self.token = ud.object(forKey: loginToken) as! String
        self.groupName = ud.object(forKey: group) as! String
        self.flag = flag
        self.t[0] = t0
        self.t[1] = t1
        self.t[2] = t2
        self.t[3] = t3
        self.t[4] = t4
        self.t[5] = t5
        self.t[6] = t6
        self.t[7] = t7
        self.weekDay = sendWeek
    }
    //グループ削除、ログイン
    init(email: String, password: String, flag: Flag){
        self.email = email
        self.password = password
        self.flag = flag
    }
    //グループ作成
    init(email: String, password: String, again: String, flag: Flag, groupName: String){
        self.email = email
        self.password = password
        self.again = again
        self.flag = flag
        self.groupName = groupName
    }
    deinit {
    }
    
    //入力フォーム制約
    func judg() -> String{//（半角英数字各１文字以上制限追加）
        var errorText: String = ""
        var errorFlag: Int = 0
        if email.isEmpty{
            errorText += "メールアドレスを入力してください\n"
            errorFlag = 1
        }
        else if email.count > 20 {
            errorText += "メールアドレスは２０文字以下で入力してください\n"
            errorFlag = 1
        }
        if password.isEmpty {
            errorText += "パスワードを入力してください\n"
            errorFlag = 1
        }
        else if password.count < 8 ||  password.count > 20 {
            errorText += "パスワードは８桁以上、２０桁以下で入力してください\n"
            errorFlag = 1
        }
        if flag == .REGISTER {
            if groupName.isEmpty{
                errorText += "グループ名を入力してください\n"
                errorFlag = 1
            }else if(groupName.count > 10){
                errorText += "グループ名は１０文字以下で入力してください\n"
                errorFlag = 1
            }
            if password != again {
                errorText += "パスワードが一致しません"
                errorFlag = 1
            }
        }
        if errorFlag == 1 {
            return errorText
        }
        return ""
    }
    
    //文字数エラー検知・空データ排除・スケジュール結合
    func linking() -> String{
        for i in 0..<t.count{
            if t[i].count > 14{
                return "各14文字以内で入力してください"
            }
            if t[i].isEmpty{
                t[i] = ""
            }
            if i < 7{
                tLink += t[i] + ","
            }else{
                tLink += t[i]
            }
        }
        return ""
    }
    
    //掲示板更新エラー検知
    func notifiJudg() -> String{
        var errorText: String = ""
        var errorFlag: Int = 0
        if text.isEmpty{
            errorText = "更新内容を入力してください"
            errorFlag = 1
        }
        if errorFlag == 1{
            return errorText
        }
        return ""
    }
    
    //データベース問い合わせ
    func login() -> String{
        var reply: String = ""
        let postData: String = "email=" + email + "&password=" + password + "&flag=" + flag.flagName()
        var request = URLRequest(url: URL(string: "https://kudkun.com/schedule/rorl.php")!)
        request.httpMethod = "POST"
        request.httpBody = postData.data(using: .utf8)
        let session = URLSession.shared.dataTask(with: request,completionHandler: { (data, response, error) in
            if data == nil || error != nil{
                reply = serverError
                return
            }
            reply = String(data: data!,encoding: .utf8)!
            
            if !reply.contains("アカウントが存在しません") && !reply.contains(serverError){
                //ログイントークン、グループ名を保持
                let result: [String] = reply.components(separatedBy: "\n")
                ud.set(result[0], forKey: loginToken)
                ud.set(result[1], forKey: group)
                ud.synchronize()
            }

        })
        session.resume()
        Thread.sleep(forTimeInterval: 1)
        return reply
    }
    
    func kill() -> String{
        var reply: String = ""
        let postData: String = "email=" + email + "&password=" + password + "&flag=" + flag.flagName()
        var request = URLRequest(url: URL(string: "https://kudkun.com/schedule/rorl.php")!)
        request.httpMethod = "POST"
        request.httpBody = postData.data(using: .utf8)
        let session = URLSession.shared.dataTask(with: request,completionHandler: { (data, response, error) in
            if data == nil || error != nil{
                reply = serverError
                return
            }
            reply = String(data: data!,encoding: .utf8)!
        })
        session.resume()
        Thread.sleep(forTimeInterval: 1)
        return reply
    }
    
    func register() -> String{
        var reply: String = ""
        let postData: String = "email=" + email + "&password=" + password + "&flag=" + flag.flagName() + "&groupName=" + self.groupName
        var request = URLRequest(url: URL(string: "https://kudkun.com/schedule/rorl.php")!)
        request.httpMethod = "POST"
        request.httpBody = postData.data(using: .utf8)
        let session = URLSession.shared.dataTask(with: request,completionHandler: { (data, response, error) in
            if data == nil || error != nil{
                reply = serverError
                return
            }
            reply = String(data: data!,encoding: .utf8)!
        })
        session.resume()
        Thread.sleep(forTimeInterval: 1)
        return reply
    }
    
    func session() -> String{
        var reply: String = ""
        let postData: String = "flag=" + flag.flagName() + "&token=" + token
        var request = URLRequest(url: URL(string: "https://kudkun.com/schedule/rorl.php")!)
        request.httpMethod = "POST"
        request.httpBody = postData.data(using: .utf8)
        let session = URLSession.shared.dataTask(with: request,completionHandler: { (data, response, error) in
            if data == nil || error != nil{
                reply = serverError
                return
            }
            reply = String(data: data!,encoding: .utf8)!
        })
        session.resume()
        Thread.sleep(forTimeInterval: 1)
        return reply
    }
    
    func getGroup() -> String{
        var reply: String = ""
        let postData: String = "flag=" + flag.flagName()
        var request = URLRequest(url: URL(string: "https://kudkun.com/schedule/rorl.php")!)
        request.httpMethod = "POST"
        request.httpBody = postData.data(using: .utf8)
        let session = URLSession.shared.dataTask(with: request,completionHandler: { (data, response, error) in
            if data == nil || error != nil{
                reply = serverError
                return
            }
            reply = String(data: data!,encoding: .utf8)!
        })
        session.resume()
        Thread.sleep(forTimeInterval: 1)
        return reply
    }
    
    //不正容易
    func wSchedule() -> String{
        var reply: String = ""
        let postData: String = "flag=" + flag.flagName() + "&groupName=" + self.groupName + "&t=" + tLink + "&weekDay=" + weekDay
        var request = URLRequest(url: URL(string: "https://kudkun.com/schedule/rorl.php")!)
        request.httpMethod = "POST"
        request.httpBody = postData.data(using: .utf8)
        let session = URLSession.shared.dataTask(with: request,completionHandler: { (data, response, error) in
            if data == nil || error != nil{
                reply = serverError
                return
            }
            reply = String(data: data!,encoding: .utf8)!
        })
        session.resume()
        Thread.sleep(forTimeInterval: 1)
        return reply
    }
    
    func rSchedule() -> String{
        var reply: String = ""
        let postData: String = "flag=" + flag.flagName() + "&groupName=" + self.groupName + "&weekDay=" + weekDay
        var request = URLRequest(url: URL(string: "https://kudkun.com/schedule/rorl.php")!)
        request.httpMethod = "POST"
        request.httpBody = postData.data(using: .utf8)
        let session = URLSession.shared.dataTask(with: request,completionHandler: { (data, response, error) in
            if data == nil || error != nil{
                reply = serverError
                return
            }
            reply = String(data: data!,encoding: .utf8)!
        })
        session.resume()
        Thread.sleep(forTimeInterval: 1)
        return reply
    }
    
    //不正容易
    func wBulletin() -> String{
        var reply: String = ""
        let postData: String = "flag=" + flag.flagName() + "&groupName=" + self.groupName + "&text=" + text
        var request = URLRequest(url: URL(string: "https://kudkun.com/schedule/rorl.php")!)
        request.httpMethod = "POST"
        request.httpBody = postData.data(using: .utf8)
        let session = URLSession.shared.dataTask(with: request,completionHandler: { (data, response, error) in
            if data == nil || error != nil{
                reply = serverError
                return
            }
            reply = String(data: data!,encoding: .utf8)!
        })
        session.resume()
        Thread.sleep(forTimeInterval: 1)
        return reply
    }
    
    func rBulletin() -> String{
        var reply: String = ""
        let postData: String = "flag=" + flag.flagName() + "&groupName=" + self.groupName
        var request = URLRequest(url: URL(string: "https://kudkun.com/schedule/rorl.php")!)
        request.httpMethod = "POST"
        request.httpBody = postData.data(using: .utf8)
        let session = URLSession.shared.dataTask(with: request,completionHandler: { (data, response, error) in
            if data == nil || error != nil{
                reply = serverError
                return
            }
            reply = String(data: data!,encoding: .utf8)!
        })
        session.resume()
        Thread.sleep(forTimeInterval: 1)
        return reply
    }
    
    func nowSub() -> String{
        var reply: String = ""
        let postData: String = "flag=" + flag.flagName() + "&groupName=" + self.groupName
        var request = URLRequest(url: URL(string: "https://kudkun.com/schedule/rorl.php")!)
        request.httpMethod = "POST"
        request.httpBody = postData.data(using: .utf8)
        let session = URLSession.shared.dataTask(with: request,completionHandler: { (data, response, error) in
            if data == nil || error != nil{
                reply = serverError
                return
            }
            reply = String(data: data!,encoding: .utf8)!
        })
        session.resume()
        Thread.sleep(forTimeInterval: 1)
        return reply
    }
    
    func nextSub() -> String{
        var reply: String = ""
        let postData: String = "flag=" + flag.flagName() + "&groupName=" + self.groupName
        var request = URLRequest(url: URL(string: "https://kudkun.com/schedule/rorl.php")!)
        request.httpMethod = "POST"
        request.httpBody = postData.data(using: .utf8)
        let session = URLSession.shared.dataTask(with: request,completionHandler: { (data, response, error) in
            if data == nil || error != nil{
                reply = serverError
                return
            }
            reply = String(data: data!,encoding: .utf8)!
        })
        session.resume()
        Thread.sleep(forTimeInterval: 1)
        return reply
    }
}
