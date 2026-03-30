//
//  AuthCoordinator.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 9/28/25.
//

import UIKit

final class AuthCoordinator: NavigationCoordinator {
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
           viewModel.onRoute = { [weak self] route in
               DispatchQueue.main.async {
                   self?.handleLoginRoute(route)
               }
           }

           let vc = LoginViewController(viewModel: viewModel)
           navigationController.setViewControllers([vc], animated: true)
       }
    func showSignUpScreen(email:String){
        let viewModel = RegisterViewModel()
        viewModel.onRoute = { [weak self] route in
            DispatchQueue.main.async {
                self?.handleRegisterRoute(route)
            }
        }
        viewModel.email = email
        let vc = RegisterViewController(viewModel: viewModel)
        navigationController.pushViewController(vc, animated: true)
    }


    func showForgotPasswordEmailScreen(email:String) {
        let viewModel = ForgotPasswordViewModel()
        viewModel.email = email
        viewModel.onRoute = { [weak self] route in
            DispatchQueue.main.async {
                self?.handleForgotPasswordRoute(route)
            }
        }
        let vc = ForgetPasswordEmailViewController(viewModel: viewModel)
        navigationController.pushViewController(vc, animated: true)
    }

    func showForgotPasswordSetNewPasswordScreen(finished:@escaping ()->()) {
        let viewModel = ForgotPasswordViewModel()
        viewModel.onRoute = { [weak self] route in
            DispatchQueue.main.async {
                self?.handleForgotPasswordRoute(route, finished: finished)
            }
        }
        let resetVC = ForgotPasswordChangeVIew(viewModel: viewModel)
      resetVC.modalPresentationStyle = .automatic
        navigationController.present(resetVC, animated: true)
    }

}

extension AuthCoordinator {
    private func handleLoginRoute(_ route: LoginRoute) {
        switch route {
        case .signUp(let email):
            showSignUpScreen(email: email)
        case .forgotPassword(let email):
            showForgotPasswordEmailScreen(email: email)
        }
    }

    private func handleRegisterRoute(_ route: RegisterRoute) {
        switch route {
        case .showConfirmAlert(let email, let type):
            showConfirmAlert(email: email, type: type)
        }
    }

    private func handleForgotPasswordRoute(_ route: ForgotPasswordRoute, finished: (() -> Void)? = nil) {
        switch route {
        case .showConfirmAlert(let email, let type):
            showConfirmAlert(email: email, type: type)
        case .passwordChanged:
            let presenter = navigationController.presentedViewController ?? navigationController
            showAlert(
                title: "Changed Your Password",
                message: "You can now enter with new password.",
                presenter: presenter
            ) { [weak self] in
                self?.navigationController.dismiss(animated: true)
                finished?()
            }
        }
    }
}

enum ConfirmAlerrType {
   case passwordReset, emailVerification
}
extension AuthCoordinator {

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
            presenter: UIViewController? = nil,
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

            (presenter ?? self.navigationController).present(alert, animated: true)
        }

}
