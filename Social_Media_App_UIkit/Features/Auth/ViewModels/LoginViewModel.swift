//
//  LoginViewModel.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 9/23/25.
//

import UIKit
import AuthenticationServices
import Combine

enum LoginRoute {
    case signUp(email: String)
    case forgotPassword(email: String)
}

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var email:String = ""
    @Published var password:String = ""

    @Published var loginError: AuthError?
    @Published var isLoading: Bool = false
    var onRoute: ((LoginRoute) -> Void)?

    private let authService: AuthServicing
    private let socialAuthService: SocialAuthServicing

    init(authService: AuthServicing, socialAuthService: SocialAuthServicing) {
        self.authService = authService
        self.socialAuthService = socialAuthService
    }

    func login() {
        loginError = nil
        guard email.isValidEmail else {
            newError(AuthError.invalidEmail)
            return
        }

        guard !password.isEmpty else {
            newError(AuthError.invalidPasswordEmpty)
            return
        }

        guard password.count >= 6 else {
            newError(AuthError.invalidPasswordTooShort)
            return
        }
        isLoading = true
        Task {
            do {
                _ = try await authService.signIn(email: email, password: password)
            } catch {
                newError(error)
            }
            isLoading = false
        }
    }

    func forgotPassword(){
        onRoute?(.forgotPassword(email: email))
    }

    func signInWithGoogle(viewController: UIViewController) {
        isLoading = true
        Task {
            do {
                _ = try await socialAuthService.signInWithGoogle(from: viewController)
                loginError = nil
            } catch {
                newError(error)
            }
            isLoading = false
        }
    }

    
    func signInWithApple(presentationContextProvider: ASAuthorizationControllerPresentationContextProviding) {
        isLoading = true
        Task {
            do {
                _ = try await socialAuthService.signInWithApple(
                    presentationContextProvider: presentationContextProvider
                )
                loginError = nil
            } catch {
                newError(error)
            }
            isLoading = false
        }
    }

    func goToSignUP(){
        onRoute?(.signUp(email: email))
    }

    func newError(_ error: Error){
        if let error = error as? AuthError {
            self.loginError = error
        } else {
            let error = AuthError.mapSupabaseError(error)
            self.loginError = error
        }
    }
}
