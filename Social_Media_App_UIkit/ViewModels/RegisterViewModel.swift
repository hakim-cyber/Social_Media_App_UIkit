//
//  RegisterViewModel.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 9/26/25.
//


import UIKit
import AuthenticationServices
import Combine
internal import Auth
class RegisterViewModel:ObservableObject{
    @Published var email:String = ""
    @Published var password:String = ""
    @Published var confirmPassword:String = ""
    
    @Published var loginError: AuthError?
    @Published var isLoading: Bool = false
    
  // returns email to show in alert
    func signUp(complete: @escaping (String) -> Void){
        // Reset previous error
        isLoading = true
        loginError = nil
        
        // Validate email
        guard email.isValidEmail else {
            newError(AuthError.invalidEmail)
           return
        }
        
        // Validate password
        guard !password.isEmpty else {
            newError(AuthError.invalidPasswordEmpty)
            return
        }
        
        guard password.count >= 6 else {
            newError(AuthError.invalidPasswordTooShort)
            return
        }
        
        guard password == confirmPassword else {
            newError(AuthError.passwordsDoNotMatch)
            return
        }
        Task{
            do{
                let user =  try await  AuthService.shared.signUp(email: email, password: password)
                if let email = user.email{
                    complete( email)
                }
            }catch{
                print(error)
               newError(error)
                
            }
            isLoading = false
        }
        
    }
    
    func signInWithGoogle(viewController:UIViewController){
        isLoading = true
        AuthService.shared.signInWithGoogleUI(viewController: viewController) {  [weak self]  result in
            guard let self = self else { return }
            switch result {
            case .success(let user):
                self.loginError = nil
            case .failure(let error):
                self.newError(error)
            }
            self.isLoading = false
        }
       
    }
    // MARK: - Apple Sign In
    func signInWithApple(presentationContextProvider:ASAuthorizationControllerPresentationContextProviding){
        isLoading = true
        
        AuthService.shared.signInWithAppleUI(presentationContextProvider: presentationContextProvider){[weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let user):
                self.loginError = nil
            case .failure(let error):
                self.newError(error)
            }
            self.isLoading = false
        }
    }
    
   
    // MARK: - Helper functions
    
    func newError(_ error:Error){
        if let error = error as? AuthError {
            self.loginError = error
        }else{
          let error =  AuthError.mapSupabaseError(error)
            self.loginError = error
        }
    }
   
}
