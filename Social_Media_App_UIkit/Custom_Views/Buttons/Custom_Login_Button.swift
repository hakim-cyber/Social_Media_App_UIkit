//
//  Custom_Login_Button.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 9/23/25.
//

import Foundation
import UIKit

class Custom_Login_Button: UIButton {
   

        override init(frame: CGRect) {
            super.init(frame: frame)
            configure()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

    init(backgroundColor:UIColor,title:String,cornerRadius:CGFloat = 10){
          
            super.init(frame: .zero)
            self.layer.cornerRadius = cornerRadius
            self.backgroundColor = backgroundColor
            self.setTitle(title, for: .normal)
    
            configure()
        }
        private func configure(){
            
            
            
            configuration?.imagePadding = 0
            setTitleColor(.white, for: .normal)
            titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            translatesAutoresizingMaskIntoConstraints = false
        }
      
}
