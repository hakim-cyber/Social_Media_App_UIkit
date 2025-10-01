//
//  AuthCoordinator.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 9/28/25.
//

import UIKit

final class AuthCoordinator: Coordinator {
    var navigationController: UINavigationController
    let onboardingService: OnboardingService

    init(navigationController: UINavigationController,onboardingService:OnboardingService) {
        self.navigationController = navigationController
        self.onboardingService = onboardingService
    }

    func start(animated: Bool = true) {
        if !onboardingService.hasSeenWelcome {
            showWelcomeScreen()
        }else{
            showLoginScreen()
        }
    }

    // MARK: - Screens
       
       func showWelcomeScreen() {
           let welcomeVC = WelcomeViewController()
           welcomeVC.onUnlock = { [weak self] in
               self?.onboardingService.setHasSeenWelcome()
               self?.showLoginScreen()
           }
           navigationController.setViewControllers([welcomeVC], animated: true)
       }
       
       func showLoginScreen() {
           let viewModel = LoginViewModel()
           viewModel.delegate = self
           let vc = LoginViewController(viewModel: viewModel)
           navigationController.setViewControllers([vc], animated: true)
       }
    func showSignUpScreen(email:String){
        let viewModel = RegisterViewModel()
        viewModel.delegate = self
        viewModel.email = email
        let vc = RegisterViewController(viewModel: viewModel)
        navigationController.pushViewController(vc, animated: true)
    }
    
    
    func showForgotPasswordEmailScreen(email:String) {
        let viewModel = ForgotPasswordViewModel()
        viewModel.email = email
        viewModel.delegate = self
        let vc = ForgetPasswordEmailViewController(viewModel: viewModel)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showForgotPasswordSetNewPasswordScreen() {
        let viewModel = ForgotPasswordViewModel()
        viewModel.delegate = self
        let resetVC = ForgotPasswordChangeVIew(viewModel: viewModel)
      resetVC.modalPresentationStyle = .automatic
        navigationController.present(resetVC, animated: true)
    }
    
}


enum ConfirmAlerrType {
   case passwordReset, emailVerification
}
protocol AuthViewModelDelegate: AnyObject {
    
    func showConfirmAlert(email:String,type:ConfirmAlerrType)
    func showForgotPasswordEmailScreen(email:String)
    func showSignUpScreen(email:String)
}
extension AuthCoordinator: AuthViewModelDelegate {
     
    func showConfirmAlert(email: String,type:ConfirmAlerrType) {
        switch type {
       
        case .passwordReset:
            self.showAlert(title: "Check Your Email", message:  "A password reset link has been sent to \(email).") {[weak self] in
                self?.navigationController.popViewController(animated: true)
            }
        case .emailVerification:
            showAlert(
                title: "Verify Email",
                message: "We sent a confirmation link to \(email). Please verify before logging in."
            ) { [weak self] in
                self?.navigationController.popViewController(animated: true)
            }
        }
        }
    
   
        func showAlert(
            title: String,
            message: String,
            okTitle: String = "OK",
            onOk: (() -> Void)? = nil
        ) {
            let alert = UIAlertController(
                title: title,
                message: message,
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: okTitle, style: .default) { _ in
                onOk?()
            })
            
            self.navigationController.present(alert, animated: true)
        }
    
}
