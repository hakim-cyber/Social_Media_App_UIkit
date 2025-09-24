//
//  UITextField+Extension.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 9/25/25.
//

import UIKit

extension UITextField {
    func addDoneButton(title: String = "Done", target: Any?, selector: Selector?) {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: title, style: UIBarButtonItem.Style.prominent, target: target, action: selector)
        doneButton.tintColor = UIColor.electricPurple
        toolbar.items = [flexible, doneButton]
        self.inputAccessoryView = toolbar
    }
}
