//
//  PreviewAuthServices.swift
//  Social_Media_App_UIkit
//
//  Created by Codex on 4/1/26.
//

import UIKit
import AuthenticationServices
import Supabase

#if DEBUG
@MainActor
final class PreviewAuthService: AuthServicing {
    func refreshSessionIfNeeded() async throws {}
    func signIn(email: String, password: String) async throws -> User { throw AuthError.userNotFound }
    func signUp(email: String, password: String) async throws -> User { throw AuthError.userNotFound }
    func signInWithApple(idToken: String, nonce: String) async throws -> User { throw AuthError.userNotFound }
    func signInWithGoogle(idToken: String) async throws -> User { throw AuthError.userNotFound }
    func restoreSession(from url: URL) async throws -> User { throw AuthError.userNotFound }
    func sendPasswordReset(email: String) async throws {}
    func changePassword(currentPassword: String, newPassword: String) async throws {}
    func updatePassword(newPassword: String) async throws -> User { throw AuthError.userNotFound }
    func logout() async throws {}
}

@MainActor
final class PreviewSocialAuthService: SocialAuthServicing {
    func signInWithGoogle(from viewController: UIViewController) async throws -> User {
        throw AuthError.userNotFound
    }

    func signInWithApple(
        presentationContextProvider: ASAuthorizationControllerPresentationContextProviding
    ) async throws -> User {
        throw AuthError.userNotFound
    }
}
#endif
