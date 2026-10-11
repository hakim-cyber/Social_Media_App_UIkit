//
//  AuthService.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 9/20/25.
//

import Foundation
import Supabase

@MainActor
protocol AuthServicing {
    func refreshSessionIfNeeded() async throws
    func signIn(email: String, password: String) async throws -> User
    func signUp(email: String, password: String) async throws -> User
    func signInWithApple(idToken: String, nonce: String) async throws -> User
    func signInWithGoogle(idToken: String) async throws -> User
    func restoreSession(from url: URL) async throws -> User
    func sendPasswordReset(email: String) async throws
    func changePassword(currentPassword: String, newPassword: String) async throws
    func updatePassword(newPassword: String) async throws -> User
    func logout() async throws
}

@MainActor
final class AuthService: AuthServicing {
    private let supabase: SupabaseClient
    private let sessionStore: SessionStoreProtocol
    private let passwordResetRedirectURL: URL

    init(
        client: SupabaseClient,
        sessionStore: SessionStoreProtocol,
        passwordResetRedirectURL: URL
    ) {
        self.supabase = client
        self.sessionStore = sessionStore
        self.passwordResetRedirectURL = passwordResetRedirectURL
    }

    func refreshSessionIfNeeded() async throws {
        let session = try await supabase.auth.refreshSession()
        sessionStore.setSession(
            user: session.user,
            accessToken: session.accessToken,
            refreshToken: session.refreshToken
        )
    }

    func logout() async throws {
        try await supabase.auth.signOut()
        sessionStore.clearSession()
    }

    func signIn(email: String, password: String) async throws -> User {
        let session = try await supabase.auth.signIn(email: email, password: password)
        sessionStore.setSession(
            user: session.user,
            accessToken: session.accessToken,
            refreshToken: session.refreshToken
        )
        return session.user
    }

    func signUp(email: String, password: String) async throws -> User {
        let session = try await supabase.auth.signUp(email: email, password: password)
        return session.user
    }

    func signInWithApple(idToken: String, nonce: String) async throws -> User {
        let session = try await supabase.auth.signInWithIdToken(
            credentials: .init(provider: .apple, idToken: idToken, nonce: nonce)
        )
        sessionStore.setSession(
            user: session.user,
            accessToken: session.accessToken,
            refreshToken: session.refreshToken
        )
        return session.user
    }

 
    func signInWithGoogle(idToken: String) async throws -> User {
        let session = try await supabase.auth.signInWithIdToken(
            credentials: .init(provider: .google, idToken: idToken)
        )
        sessionStore.setSession(
            user: session.user,
            accessToken: session.accessToken,
            refreshToken: session.refreshToken
        )
        return session.user
    }

    func restoreSession(from url: URL) async throws -> User {
        let session = try await supabase.auth.session(from: url)
        sessionStore.setSession(
            user: session.user,
            accessToken: session.accessToken,
            refreshToken: session.refreshToken
        )
        return session.user
    }

    func sendPasswordReset(email: String) async throws {
        try await supabase.auth.resetPasswordForEmail(
            email,
            redirectTo: passwordResetRedirectURL
        )
    }

    func changePassword(currentPassword: String, newPassword: String) async throws {
        guard let email = sessionStore.currentUser?.email else {
            throw AuthError.userNotFound
        }

        let session = try await supabase.auth.signIn(email: email, password: currentPassword)
        sessionStore.setSession(
            user: session.user,
            accessToken: session.accessToken,
            refreshToken: session.refreshToken
        )
        _ = try await updatePassword(newPassword: newPassword)
    }

    func updatePassword(newPassword: String) async throws -> User {
        try await supabase.auth.update(user: UserAttributes(password: newPassword))
    }
}
