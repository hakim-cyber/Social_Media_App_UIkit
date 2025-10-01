//
//  UITextField+Extension.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 9/25/25.
//



import UIKit

extension UIResponder {
    func addDoneButton(title: String = "Done", target: Any?, selector: Selector?) {
        // Only apply to text input views
        guard self is UITextField || self is UITextView else { return }
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(
            title: title,
            style: UIBarButtonItem.Style.prominent, // .done is correct style
            target: target,
            action: selector
        )
        doneButton.tintColor = UIColor.electricPurple // or your .electricPurple
        
        toolbar.items = [flexible, doneButton]
        
        if let textField = self as? UITextField {
            textField.inputAccessoryView = toolbar
        } else if let textView = self as? UITextView {
            textView.inputAccessoryView = toolbar
        }
    }
}
