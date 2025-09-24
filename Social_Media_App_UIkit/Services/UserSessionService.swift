//
//  UserSessionService.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 9/20/25.
//
import Foundation
import Supabase
import Combine
final class UserSessionService {
    static let shared = UserSessionService()
    private init() {}
    
    @Published var currentUser: User?
    @Published var accessToken: String?
      @Published var refreshToken: String?
      @Published var isLoggedIn: Bool = false
 
    // MARK: - Load session from Keychain
       private func loadSessionFromKeychain() {
           accessToken = KeychainService.shared.getAccessToken()
           refreshToken = KeychainService.shared.getRefreshToken()
           // You can optionally load userID as well
           isLoggedIn = accessToken != nil
       }
    
    // MARK: - Set new session
       func setSession(user: User, accessToken: String, refreshToken: String) {
           self.currentUser = user
           self.accessToken = accessToken
           self.refreshToken = refreshToken
           self.isLoggedIn = true
           
           // Save to Keychain
           do {
               try KeychainService.shared.saveAccessToken(accessToken)
               try KeychainService.shared.saveRefreshToken(refreshToken)
               try KeychainService.shared.saveUserID(user.id.uuidString)
           } catch {
               print("Keychain error:", error)
           }
       }
    
    // MARK: - Clear session (Logout)
       func clearSession() {
           currentUser = nil
           accessToken = nil
           refreshToken = nil
           isLoggedIn = false
           
           // Remove from Keychain
           do {
               try KeychainService.shared.clearAll()
           } catch {
               print("Keychain error:", error)
           }
       }
}
