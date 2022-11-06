//
//  new_account.swift
//  Task
//
//  Created by We on 2018/09/27.
//  Copyright © 2018年 We. All rights reserved.
//

import UIKit

class new_account: UIViewController, UITextFieldDelegate{
    @IBOutlet var register: UIButton!
    @IBOutlet var email: UITextField!
    @IBOutlet var password: UITextField!
    @IBOutlet var again: UITextField!
    @IBOutlet var result: UITextView!
    @IBOutlet var back: UIButton!
    @IBOutlet var groupName: UITextField!

    @IBAction func register(_ sender: UIButton){
        let f = Func(email: email.text!, password: password.text!, again: again.text!, flag: .REGISTER, groupName: groupName.text!)
        //メアド等の検証
        var rst: String = f.judg()
        if !rst.isEmpty{
            self.result.text = rst
            return
        }
        
        //アカウント登録、登録完了or失敗表示
        rst = f.register()
        self.result.text = rst
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.result.isEditable = false
        
        groupName.returnKeyType = UIReturnKeyType.done
        email.keyboardType = UIKeyboardType.emailAddress
        email.returnKeyType = UIReturnKeyType.done
        password.returnKeyType = UIReturnKeyType.done
        again.returnKeyType = UIReturnKeyType.done
        groupName.delegate = self
        email.delegate = self
        password.delegate = self
        again.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        groupName.resignFirstResponder()
        email.resignFirstResponder()
        password.resignFirstResponder()
        again.resignFirstResponder()
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
