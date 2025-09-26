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
    
    @Published var loginError: AuthError?
    @Published var isLoading: Bool = false
    
    func login() {
        // Reset previous error
        isLoading = true
        loginError = nil
        
        // Validate email
        guard isValidEmail(email) else {
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
        Task{
            do{
                let user =  try await  AuthService.shared.signIn(email: email, password: password)
               
            }catch{
                print(error)
               newError(error)
               
            }
            isLoading = false
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
                    self.newError(error)
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
                            self.newError(error)
                          
                        }
                        self.isLoading = false
                    }
                }
    }
    
    
    func signUp(){
        
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
