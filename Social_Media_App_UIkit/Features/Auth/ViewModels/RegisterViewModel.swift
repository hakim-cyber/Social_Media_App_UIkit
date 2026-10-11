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

enum RegisterRoute {
    case showConfirmAlert(email: String, type: ConfirmAlerrType)
}

@MainActor
final class RegisterViewModel: ObservableObject {
    @Published var email:String = ""
    @Published var password:String = ""
    @Published var confirmPassword:String = ""

    @Published var loginError: AuthError?
    @Published var isLoading: Bool = false
    var onRoute: ((RegisterRoute) -> Void)?

    private let authService: AuthServicing
    private let socialAuthService: SocialAuthServicing

    init(authService: AuthServicing, socialAuthService: SocialAuthServicing) {
        self.authService = authService
        self.socialAuthService = socialAuthService
    }

    func signUp(){
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

        guard password == confirmPassword else {
            newError(AuthError.passwordsDoNotMatch)
            return
        }

        isLoading = true
        Task {
            do {
                let user = try await authService.signUp(email: email, password: password)
                if let email = user.email {
                    onRoute?(.showConfirmAlert(email: email, type: .emailVerification))
                }
            } catch {
                newError(error)
            }
            isLoading = false
        }
    }

    func signInWithGoogle(viewController: UIViewController){
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

    func signInWithApple(presentationContextProvider: ASAuthorizationControllerPresentationContextProviding){
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

    func newError(_ error:Error){
        if let error = error as? AuthError {
            self.loginError = error
        } else {
            let error = AuthError.mapSupabaseError(error)
            self.loginError = error
        }
    }
}
