//
//  ForgotPasswordViewModelMocks.swift
//  Social_Media_App_UIkitTests
//
//  Created by Codex on 4/26/26.
//

import Supabase
import Foundation
@testable import Social_Media_App_UIkit

@MainActor
final class ForgotPasswordViewModelMockAuthService: AuthServicing {
    var updatePasswordResult: Result<User, Error> = .success(
        User(
            id: UUID(),
            appMetadata: [:],
            userMetadata: [:],
            aud: "authenticated",
            email: "reset@mail.com",
            createdAt: .now,
            updatedAt: .now
        )
    )
    var sendPasswordResetResult: Result<Void, Error> = .success(())

    private(set) var sendPasswordResetCallCount = 0
    private(set) var updatePasswordCallCount = 0

    func refreshSessionIfNeeded() async throws {}

    func signIn(email: String, password: String) async throws -> User {
        throw ForgotPasswordViewModelTestError("Not used in tests")
    }

    func signUp(email: String, password: String) async throws -> User {
        throw ForgotPasswordViewModelTestError("Not used in tests")
    }

    func signInWithApple(idToken: String, nonce: String) async throws -> User {
        throw ForgotPasswordViewModelTestError("Not used in tests")
    }

    func signInWithGoogle(idToken: String) async throws -> User {
        throw ForgotPasswordViewModelTestError("Not used in tests")
    }

    func restoreSession(from url: URL) async throws -> User {
        throw ForgotPasswordViewModelTestError("Not used in tests")
    }

    func sendPasswordReset(email: String) async throws {
        sendPasswordResetCallCount += 1
        _ = try sendPasswordResetResult.get()
    }

    func changePassword(currentPassword: String, newPassword: String) async throws {}

    func updatePassword(newPassword: String) async throws -> User {
        updatePasswordCallCount += 1
        return try updatePasswordResult.get()
    }

    func logout() async throws {}
}

struct ForgotPasswordViewModelTestError: LocalizedError {
    let message: String

    init(_ message: String) {
        self.message = message
    }

    var errorDescription: String? {
        message
    }
}
