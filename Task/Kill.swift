//
//  Kill.swift
//  Task
//
//  Created by We on 2018/09/29.
//  Copyright © 2018年 We. All rights reserved.
//

import UIKit

class Kill: UIViewController, UITextFieldDelegate{
    @IBOutlet var email: UITextField!
    @IBOutlet var password: UITextField!
    @IBOutlet var kill: UIButton!
    @IBOutlet var result: UITextView!
    @IBOutlet var back: UIButton!
    
    @IBAction func kill(_ sender: UIButton){
        let f = Func(email: email.text!,password: password.text!, flag: .KILL)
        //メアド等のエラー検証
        var rst: String = f.judg()
        if !rst.isEmpty{
            self.result.text = rst
            return
        }
        
        //アカウント削除、削除完了or失敗表示
        rst = f.kill()
        self.result.text = rst
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.result.isEditable = false
        
        email.keyboardType = UIKeyboardType.emailAddress
        email.returnKeyType = UIReturnKeyType.done
        password.returnKeyType = UIReturnKeyType.done
        email.delegate = self
        password.delegate = self
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
