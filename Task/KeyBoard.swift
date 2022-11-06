//
//  KeyBoard.swift
//  Task
//
//  Created by 川口凜花 on 2018/12/06.
//  Copyright © 2018年 ITユーザー. All rights reserved.
//

import Foundation
import UIKit

class KeyBoard: UITextField{
    override init(frame: CGRect){
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit(){
        let tools = UIToolbar()
        tools.frame = CGRect(x:0,y:0,width:frame.width,height:40)
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let closeButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(KeyBoard.closeButtonTapped))
        tools.items = [spacer,closeButton]
        self.inputAccessoryView = tools
    }
    
    func closeButtonTapped(){
        self.endEditing(true)
        self.resignFirstResponder()
    }
}
