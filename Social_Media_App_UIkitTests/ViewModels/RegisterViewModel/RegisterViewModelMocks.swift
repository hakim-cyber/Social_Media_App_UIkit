//
//  RegisterViewModelMocks.swift
//  Social_Media_App_UIkitTests
//
//  Created by Codex on 4/26/26.
//

import UIKit
import Supabase
import AuthenticationServices
@testable import Social_Media_App_UIkit

@MainActor
final class RegisterViewModelMockAuthService: AuthServicing {
    var signUpResult: Result<User, Error> = .success(
        User(
            id: UUID(),
            appMetadata: [:],
            userMetadata: [:],
            aud: "authenticated",
            email: "register@mail.com",
            createdAt: .now,
            updatedAt: .now
        )
    )

    private(set) var signUpCallCount = 0

    func refreshSessionIfNeeded() async throws {}

    func signIn(email: String, password: String) async throws -> User {
        throw RegisterViewModelTestError("Not used in tests")
    }

    func signUp(email: String, password: String) async throws -> User {
        signUpCallCount += 1
        return try signUpResult.get()
    }

    func signInWithApple(idToken: String, nonce: String) async throws -> User {
        throw RegisterViewModelTestError("Not used in tests")
    }

    func signInWithGoogle(idToken: String) async throws -> User {
        throw RegisterViewModelTestError("Not used in tests")
    }

    func restoreSession(from url: URL) async throws -> User {
        throw RegisterViewModelTestError("Not used in tests")
    }

    func sendPasswordReset(email: String) async throws {}

    func changePassword(currentPassword: String, newPassword: String) async throws {}

    func updatePassword(newPassword: String) async throws -> User {
        throw RegisterViewModelTestError("Not used in tests")
    }

    func logout() async throws {}
}

@MainActor
final class RegisterViewModelMockSocialAuthService: SocialAuthServicing {
    var googleResult: Result<User, Error> = .success(
        User(
            id: UUID(),
            appMetadata: [:],
            userMetadata: [:],
            aud: "authenticated",
            email: "google@mail.com",
            createdAt: .now,
            updatedAt: .now
        )
    )

    var appleResult: Result<User, Error> = .success(
        User(
            id: UUID(),
            appMetadata: [:],
            userMetadata: [:],
            aud: "authenticated",
            email: "apple@mail.com",
            createdAt: .now,
            updatedAt: .now
        )
    )

    private(set) var googleSignInCallCount = 0
    private(set) var appleSignInCallCount = 0

    func signInWithGoogle(from viewController: UIViewController) async throws -> User {
        googleSignInCallCount += 1
        return try googleResult.get()
    }

    func signInWithApple(
        presentationContextProvider: ASAuthorizationControllerPresentationContextProviding
    ) async throws -> User {
        appleSignInCallCount += 1
        return try appleResult.get()
    }
}

struct RegisterViewModelTestError: LocalizedError {
    let message: String

    init(_ message: String) {
        self.message = message
    }

    var errorDescription: String? {
        message
    }
}
