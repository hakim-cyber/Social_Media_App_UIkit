//
//  LoginViewController.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 9/23/25.
//

import UIKit

class LoginViewController: UIViewController {
    
    let customEmailTextField = CustomTextField(placeholder: "Type your email here",topLabelText: "Email",)
    let customPasswordTextField = CustomTextField(placeholder: "Type your password here",topLabelText: "Password",isSecure: true)
    
    var viewModel = LoginViewModel()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewDidLoad() {
   
        super.viewDidLoad()
        
        
        customPasswordTextField.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(customPasswordTextField)
        
        NSLayoutConstraint.activate([
            customPasswordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 24),
            customPasswordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -24),
            customPasswordTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    
    
    
}

#Preview {
    LoginViewController()
}
