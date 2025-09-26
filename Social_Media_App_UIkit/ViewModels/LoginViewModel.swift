//
//  LoginViewModel.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 9/23/25.
//

import UIKit
import AuthenticationServices
import Combine
class LoginViewModel:ObservableObject{
    @Published var email:String = ""
    @Published var password:String = ""
    
    @Published var loginError: LoginError?
    @Published var isLoading: Bool = false
    
    func login() {
        // Reset previous error
        isLoading = true
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
        Task{
            do{
                let user =  try await  AuthService.shared.signIn(email: email, password: password)
                isLoading = false
            }catch{
                print(error)
                self.loginError = .custom(error.localizedDescription)
                
            }
        }
      
    }
    
    // Simple regex email validation
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let predicate = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return predicate.evaluate(with: email)
    }
    func forgotPassword(){
        Task{
            do{
              try await  AuthService.shared.logout()
            }catch{
                print(error)
            }
        }
        
    }
    func signInWithGoogle(viewController:UIViewController){
        isLoading = true
        GoogleSignInHelper.shared.startGoogleSignIn(viewController: viewController) {[weak self]  result in
            guard let self = self else { return }
            
            Task {
                do {
                    let idToken = try result.get()
                    let user = try await AuthService.shared.signInWithGoogle(idToken: idToken)
                    self.loginError = nil
                } catch {
                    print("Error signing in: \(error)")
                    self.loginError = .custom(error.localizedDescription)
                }
                self.isLoading = false
            }
        }
    }
    // MARK: - Apple Sign In
    func signInWithApple(presentationContextProvider:ASAuthorizationControllerPresentationContextProviding){
        isLoading = true
        
        AppleSignInHelper.shared.startSignInWithApple(presentationContextProvider: presentationContextProvider) { [weak self] result in
                    guard let self = self else { return }
                    
                    Task {
                        do {
                            let (idToken, nonce) = try result.get()
                            let user = try await AuthService.shared.signInWithApple(idToken: idToken, nonce: nonce)
                            self.loginError = nil
                        } catch {
                            self.loginError = .custom(error.localizedDescription)
                        }
                        self.isLoading = false
                    }
                }
    }
    
    
    func signUp(){
        
    }
   
}

enum LoginError: LocalizedError {
    case invalidEmail
    case invalidPasswordEmpty
    case invalidPasswordTooShort
    case custom(String)
    case defaultError
    
    var title: String {
        switch self {
        case .invalidEmail:
            return "Invalid Email"
        case .invalidPasswordEmpty:
            return "Empty Password"
        case .invalidPasswordTooShort:
            return "Password Too Short"
        case .custom(let error):
            return "Unknown Error: \(error)"
        case .defaultError:
            return "Unknown Error"
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
        case .custom(let error):
            return "Unknown Error \(error)"
        case .defaultError:
            return "Something went wrong,Please try again later"
        }
    }
    
    var errorDescription: String? { message }
}
