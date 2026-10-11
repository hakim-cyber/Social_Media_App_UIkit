//
//  AuthCoordinator.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 9/28/25.
//

import UIKit

final class AuthCoordinator: NavigationCoordinator {
    var navigationController: UINavigationController
    private let dependencies: AuthFlowDependencies
    private let authFactory:AuthFlowFactory
    
    init(
        navigationController: UINavigationController,
        dependencies: AuthFlowDependencies
    ) {
        self.navigationController = navigationController
        self.dependencies = dependencies
        self.authFactory = AuthFlowFactory(dependencies: dependencies)
    }
    
    func start(animated: Bool = true) {
        if !dependencies.onboardingService.hasSeenWelcome {
            showWelcomeScreen()
        }else{
            showLoginScreen()
        }
    }
    
    // MARK: - Screens
    
    func showWelcomeScreen() {
        let welcomeVC = authFactory.makeWelcomeVC {[weak self] in
            self?.dependencies.onboardingService.setHasSeenWelcome()
            self?.showLoginScreen()
        }
        navigationController.setViewControllers([welcomeVC], animated: true)
    }
    
    func showLoginScreen() {
        let vc = authFactory.makeLoginScreen { [weak self] route in
            self?.handleLoginRoute(route)
        }
        navigationController.setViewControllers([vc], animated: true)
    }
    func showSignUpScreen(email:String){
        let vc = authFactory.makeRegisterScreen(
            email: email,
            onRoute: { [weak self] route in
                self?.handleRegisterRoute(route)
            }
        )
        navigationController.pushViewController(vc, animated: true)
    }
    
    
    func showForgotPasswordEmailScreen(email: String) {
        let vc = authFactory.makeForgotPasswordEmailScreen(
            email: email,
            onRoute: { [weak self] route in
                self?.handleForgotPasswordRoute(route)
            }
        )
        
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showForgotPasswordSetNewPasswordScreen(
        finished: @escaping () -> Void
    ) {
        let resetVC = authFactory.makeForgotPasswordSetNewPasswordScreen(
            onRoute: { [weak self] route in
                self?.handleForgotPasswordRoute(route, finished: finished)
            }
        )
        
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
            AppAlertPresenter.showAlert(
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
            AppAlertPresenter.showAlert(title: "Check Your Email", message:  "A password reset link has been sent to \(email).",presenter: self.navigationController) {[weak self] in
                self?.navigationController.popViewController(animated: true)
            }
        case .emailVerification:
            AppAlertPresenter.showAlert(
                title: "Verify Email",
                message: "We sent a confirmation link to \(email). Please verify before logging in.",
                presenter: self.navigationController
            ) { [weak self] in
                self?.navigationController.popViewController(animated: true)
            }
        }
    }
    
    
}
