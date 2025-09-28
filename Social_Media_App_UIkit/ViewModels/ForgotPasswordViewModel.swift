//
//  ForgotPasswordViewModel.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 9/27/25.
//
import Foundation
import Combine

class ForgotPasswordViewModel {
    weak var delegate: AuthViewModelDelegate?
    @Published var email:String = ""
    
    @Published var newPassword:String = ""
    @Published var confirmPassword:String = ""
    
    
    @Published var loginError: AuthError?
    @Published var isLoading: Bool = false
    
    func changePasswordToNewOne(complete: @escaping ()->Void)  {
       
        
        guard newPassword.count >= 6 else {
            self.loginError = AuthError.invalidPasswordTooShort
            return
        }
        
        guard newPassword == confirmPassword else {
            self.loginError = AuthError.passwordsDoNotMatch
            return
        }
        isLoading = true
        
        Task{
            do{
              let newUser = try await AuthService.shared.updatePassword(newPassword: newPassword)
                complete()
            }catch{
                self.loginError = .custom(error.localizedDescription)
            }
            isLoading = false
        }
        
    }
    func sendPasswordReset()  {
        // Validate email
        guard email.isValidEmail else {
            self.loginError = AuthError.invalidEmail
            return
        }
        self.isLoading = true
        Task{
            do{
                try await AuthService.shared.sendPasswordReset(email: email)
                self.delegate?.showConfirmAlert(email: email, type: .passwordReset)
            }catch{
                self.loginError = .custom(error.localizedDescription)
            }
            isLoading = false
        }
    }
}
