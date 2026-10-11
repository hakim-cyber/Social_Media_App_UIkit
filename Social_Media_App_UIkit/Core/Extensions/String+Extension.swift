//
//  String+Extension.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 9/23/25.
//

import UIKit



extension String{
    func makeAttributedString(mainColor: UIColor = .label, secondaryColor: UIColor = .electricPurple,mainWeight: UIFont.Weight = .regular,secondaryWeight: UIFont.Weight = .semibold,size: CGFloat = 14) -> AttributedString {
        let string = self
           var attributedString = AttributedString()
           let components = string.split(separator: "*", omittingEmptySubsequences: false)
      
           for (index, component) in components.enumerated() {
               var substring = AttributedString(String(component))
            
               // Apply italic to odd components (text between asterisks)
             
               if index % 2 == 1 {
                   substring.foregroundColor = secondaryColor
                   substring.font = .systemFont(ofSize: size, weight: secondaryWeight)
                   
               }else{
                   substring.foregroundColor = mainColor
                   substring.font = .systemFont(ofSize: size, weight: mainWeight)
               }
                
               
               attributedString.append(substring)
           }
           
           return attributedString
       }

}

//MARK : Email validation
extension String {
    var isValidEmail: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return predicate.evaluate(with: self)
    }
}
