//
//  AuthService.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 9/20/25.
//

import Foundation
import Supabase

final class AuthService {
    static let shared = AuthService()
    private init() {}
    
    private let keychain = KeychainService.shared
    private let supabase = SupabaseManager.shared.client
    
    
    // MARK: - Refresh token
    func refreshSessionIfNeeded() async throws {
        guard let refreshToken = keychain.getRefreshToken() else {
            throw AuthError.noRefreshToken
        }
        let session = try await supabase.auth.refreshSession(refreshToken: refreshToken)
        UserSessionService.shared.setSession(user: session.user, accessToken: session.accessToken, refreshToken: session.refreshToken)
    }
    
    // MARK: - Logout
    func logout() async throws {
      try await  supabase.auth.signOut()
        UserSessionService.shared.clearSession()
    }
}


// MARK: - Apple Sign In
extension AuthService {
    
    func signInWithApple(idToken:String,nonce:String)async throws -> User{
        let session = try await supabase.auth.signInWithIdToken(credentials: .init(provider: .apple, idToken: idToken,nonce:nonce))
        
        
        UserSessionService.shared.setSession(user: session.user, accessToken: session.accessToken, refreshToken: session.refreshToken)
        return session.user
    }
    
}
// MARK: - Google Sign In
extension AuthService {
    
    func signInWithGoogle(idToken:String)async throws -> User{
        let session = try await supabase.auth.signInWithIdToken(credentials: .init(provider: .google, idToken: idToken))
        
        
        UserSessionService.shared.setSession(user: session.user, accessToken: session.accessToken, refreshToken: session.refreshToken)
        print("succes google")
        print(session.user)
        return session.user
    }
    
    
}


// MARK: - Errors
enum AuthError: Error {
    case noRefreshToken
}
