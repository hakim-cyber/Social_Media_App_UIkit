//
//  AuthFlowFactory.swift
//  Social_Media_App_UIkit
//
//  Created by Hakim Aliyev on 5/23/26.
//

import Foundation
import UIKit

final class AuthFlowFactory{
    private let dependencies: AuthFlowDependencies
    init(dependencies: AuthFlowDependencies) {
        self.dependencies = dependencies
    }
    
    func makeWelcomeVC(onUnlock: @escaping () -> Void)->WelcomeViewController{
        let vc = WelcomeViewController()
        vc.onUnlock = onUnlock
        return vc
    }
    func makeLoginScreen(
           onRoute: @escaping (LoginRoute) -> Void
       ) -> LoginViewController {

           let viewModel = LoginViewModel(
               authService: dependencies.authService,
               socialAuthService: dependencies.socialAuthService
           )

           viewModel.onRoute = { route in
               DispatchQueue.main.async {
                   onRoute(route)
               }
           }

           let vc = LoginViewController(viewModel: viewModel)
           return vc
       }
    func makeRegisterScreen(
            email: String,
            onRoute: @escaping (RegisterRoute) -> Void
        ) -> RegisterViewController {

            let viewModel = RegisterViewModel(
                authService: dependencies.authService,
                socialAuthService: dependencies.socialAuthService
            )

            viewModel.email = email

            viewModel.onRoute = { route in
                DispatchQueue.main.async {
                    onRoute(route)
                }
            }

            return RegisterViewController(viewModel: viewModel)
        }
    func makeForgotPasswordEmailScreen(
          email: String,
          onRoute: @escaping (ForgotPasswordRoute) -> Void
      ) -> ForgetPasswordEmailViewController {

          let viewModel = ForgotPasswordViewModel(
              authService: dependencies.authService
          )

          viewModel.email = email

          viewModel.onRoute = { route in
              DispatchQueue.main.async {
                  onRoute(route)
              }
          }

          return ForgetPasswordEmailViewController(viewModel: viewModel)
      }

      func makeForgotPasswordSetNewPasswordScreen(
          onRoute: @escaping (ForgotPasswordRoute) -> Void
      ) -> ForgotPasswordChangeVIew {

          let viewModel = ForgotPasswordViewModel(
              authService: dependencies.authService
          )

          viewModel.onRoute = { route in
              DispatchQueue.main.async {
                  onRoute(route)
              }
          }

          let vc = ForgotPasswordChangeVIew(viewModel: viewModel)
          vc.modalPresentationStyle = .automatic

          return vc
      }
}
