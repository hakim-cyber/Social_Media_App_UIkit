//
//  SocialAuthService.swift
//  Social_Media_App_UIkit
//
//  Created by Codex on 4/1/26.
//

import UIKit
import AuthenticationServices
import Supabase

@MainActor
protocol SocialAuthServicing {
    func signInWithGoogle(from viewController: UIViewController) async throws -> User
    func signInWithApple(
        presentationContextProvider: ASAuthorizationControllerPresentationContextProviding
    ) async throws -> User
}

@MainActor
final class SocialAuthService: SocialAuthServicing {
    private let authService: AuthServicing
    private let googleSignInFlow: GoogleSignInFlowPerforming
    private let appleSignInFlow: AppleSignInFlowPerforming

    init(
        authService: AuthServicing,
        googleSignInFlow: GoogleSignInFlowPerforming,
        appleSignInFlow: AppleSignInFlowPerforming
    ) {
        self.authService = authService
        self.googleSignInFlow = googleSignInFlow
        self.appleSignInFlow = appleSignInFlow
    }

    func signInWithGoogle(from viewController: UIViewController) async throws -> User {
        let idToken = try await googleSignInFlow.start(from: viewController)
        return try await authService.signInWithGoogle(idToken: idToken)
    }

    func signInWithApple(
        presentationContextProvider: ASAuthorizationControllerPresentationContextProviding
    ) async throws -> User {
        let credentials = try await appleSignInFlow.start(
            presentationContextProvider: presentationContextProvider
        )
        return try await authService.signInWithApple(
            idToken: credentials.idToken,
            nonce: credentials.nonce
        )
    }
}
