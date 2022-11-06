//
//  Group.swift
//  Task
//
//  Created by We on 2018/10/17.
//  Copyright © 2018年 ITユーザー. All rights reserved.
//

import Foundation

class Group{
    //スケジュール読み込み
    func readSchedule(groupName: String, flag: Flag) -> String{
        let postData: String = "groupName=" + groupName + "&flag=" + flag.flagName()
        var request = URLRequest(url: URL(string: "https://kudkun.site/schedule/rorl.php")!)
        request.httpMethod = "POST"
        request.httpBody = postData.data(using: .utf8)
        let session = URLSession.shared.dataTask(with: request,completionHandler: { (data, response, error) in
            if data == nil || error != nil{
                reply = "サーバーへの接続に失敗しました"
                return
            }
            //スケジュール取得
            reply = String(data: data!,encoding: .utf8)!
        })
        session.resume()
        Thread.sleep(forTimeInterval: 1)
        return reply
    }
    
    //スケジュール更新
    func writeSchedule(groupName: String, flag: Flag, t: String) -> String{
        let postData: String = "groupName=" + groupName + "&flag=" + flag.flagName() + "&t=" + t
        var request = URLRequest(url: URL(string: "https://kudkun.site/schedule/rorl.php")!)
        request.httpMethod = "POST"
        request.httpBody = postData.data(using: .utf8)
        let session = URLSession.shared.dataTask(with: request,completionHandler: { (data, response, error) in
            if data == nil || error != nil{
                reply = "サーバーへの接続に失敗しました"
                return
            }
            //更新完了or失敗
            reply = String(data: data!,encoding: .utf8)!
        })
        session.resume()
        Thread.sleep(forTimeInterval: 2)
        return reply
    }
    
    func nowSub(weekday: String, flag: String) -> String{
        let postData: String = "flag=" + flag
        var request = URLRequest(url: URL(string: "https://kudkun.site/schedule/rorl.php")!)
        request.httpMethod = "POST"
        request.httpBody = postData.data(using: .utf8)
        let session = URLSession.shared.dataTask(with: request,completionHandler: { (data, response, error) in
            if data == nil || error != nil{
                reply = "サーバーへの接続に失敗しました"
                return
            }
            //取得完了or失敗
            reply = String(data: data!,encoding: .utf8)!
        })
        session.resume()
        Thread.sleep(forTimeInterval: 2)
        return reply
    }
    
    func nextSub(weekday: String, flag: String) -> String{
        let postData: String = "flag=" + flag
        var request = URLRequest(url: URL(string: "https://kudkun.site/schedule/rorl.php")!)
        request.httpMethod = "POST"
        request.httpBody = postData.data(using: .utf8)
        let session = URLSession.shared.dataTask(with: request,completionHandler: { (data, response, error) in
            if data == nil || error != nil{
                reply = "サーバーへの接続に失敗しました"
                return
            }
            //取得完了or失敗
            reply = String(data: data!,encoding: .utf8)!
        })
        session.resume()
        Thread.sleep(forTimeInterval: 2)
        return reply
    }
}
