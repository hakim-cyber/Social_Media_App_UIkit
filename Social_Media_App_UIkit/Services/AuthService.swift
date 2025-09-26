//
//  AuthService.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 9/20/25.
//

import Foundation
import Supabase
import AuthenticationServices

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

// MARK: - Sign in/up with email
extension AuthService {
    
    
    func signIn(email: String, password: String) async throws -> User {
        
        let session = try await supabase.auth.signIn(email: email, password: password)
        print(session)
        UserSessionService.shared.setSession(user: session.user, accessToken: session.accessToken, refreshToken: session.refreshToken)
        return session.user
    }
    func signUp(email: String, password: String) async throws -> User {
        
        let session = try await supabase.auth.signUp(email: email, password: password)
        print(session.session)
        
//        UserSessionService.shared.setSession(user: session.user, accessToken: session.accessToken, refreshToken: session.refreshToken)
        return session.user
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


// MARK: - Google/Apple Sign In UI Functions

extension AuthService{
    func signInWithGoogleUI(
        viewController: UIViewController,
        completion: @escaping (Result<User, Error>) -> Void
    ) {
        GoogleSignInHelper.shared.startGoogleSignIn(viewController: viewController) { [weak self] result in
            guard let self else { return }
            Task {
                do {
                    let idToken = try result.get()
                    let user = try await self.signInWithGoogle(idToken: idToken)
                    completion(.success(user))
                } catch {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func signInWithAppleUI(
        presentationContextProvider: ASAuthorizationControllerPresentationContextProviding,
        completion: @escaping (Result<User, Error>) -> Void
    ) {
        AppleSignInHelper.shared.startSignInWithApple(presentationContextProvider: presentationContextProvider) {[weak self] result in
            guard let self else { return }
            Task {
                do {
                    let (idToken, nonce) = try result.get()
                    let user = try await self.signInWithApple(idToken: idToken, nonce: nonce)
                    completion(.success(user))
                } catch {
                    completion(.failure(error))
                }
            }
        }
    }
}



// MARK: - Apple Sign In


extension AuthService{
    func restoreSession(from url: URL) async throws -> User {
           // Supabase parses the access token from the URL and restores session
           let session = try await supabase.auth.session(from: url)
           
        print("Restored session \(session)")
           // Save session tokens locally
           UserSessionService.shared.setSession(
               user: session.user,
               accessToken: session.accessToken,
               refreshToken: session.refreshToken
           )
           
           return session.user
       }
}
