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
    private init() {
        loadSessionFromSupabase()
    }
    
    @Published var currentUser: User?
    @Published var accessToken: String?
      @Published var refreshToken: String?
      @Published var isLoggedIn: Bool = false
    
    private let supabase = SupabaseManager.shared.client
 
    // MARK: - Load session from Supabase
    private func loadSessionFromSupabase() {
        if let user =  supabase.auth.currentUser {
            self.currentUser = user
            self.isLoggedIn = true
        } else {
            self.currentUser = nil
            self.isLoggedIn = false
        }
    }
    // MARK: - Set new session
       func setSession(user: User, accessToken: String, refreshToken: String) {
           self.currentUser = user
           self.accessToken = accessToken
           self.refreshToken = refreshToken
           self.isLoggedIn = true
          
       }
    
    // MARK: - Clear session (Logout)
       func clearSession() {
           currentUser = nil
           accessToken = nil
           refreshToken = nil
           isLoggedIn = false
       }
}
