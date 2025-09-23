//
//  LoginViewModel.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 9/23/25.
//

import UIKit
import Combine
class LoginViewModel:ObservableObject{
    @Published var email:String = ""
    @Published var password:String = ""
    
    @Published var loginError: LoginError?
    
    func login() {
        // Reset previous error
        loginError = nil
        
        // Validate email
        guard isValidEmail(email) else {
            loginError = .invalidEmail
            return
        }
        
        // Validate password
        guard !password.isEmpty else {
            loginError = .invalidPasswordEmpty
            return
        }
        
        guard password.count >= 6 else {
            loginError = .invalidPasswordTooShort
            return
        }
        
      
    }
    
    // Simple regex email validation
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let predicate = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return predicate.evaluate(with: email)
    }
    func forgotPassword(){
        
    }
    func signInWithGoogle(){
        
    }
    func signInWithApple(){
        
    }
    func signUp(){
        
    }
   
}

enum LoginError: LocalizedError {
    case invalidEmail
    case invalidPasswordEmpty
    case invalidPasswordTooShort
    
    var title: String {
        switch self {
        case .invalidEmail:
            return "Invalid Email"
        case .invalidPasswordEmpty:
            return "Empty Password"
        case .invalidPasswordTooShort:
            return "Password Too Short"
        }
    }
    
    var message: String {
        switch self {
        case .invalidEmail:
            return "Your email address is not valid. Make sure it includes '@' and a domain, like 'example@mail.com'."
        case .invalidPasswordEmpty:
            return "Please enter your password."
        case .invalidPasswordTooShort:
            return "Password must be at least 6 characters long."
        }
    }
    
    var errorDescription: String? { message }
}
