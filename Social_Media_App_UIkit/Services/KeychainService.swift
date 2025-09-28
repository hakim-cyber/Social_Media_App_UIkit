//
//  KeychainService.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 9/20/25.
//
//
//import Foundation
//import KeychainAccess
//
//final class KeychainService {
//    static let shared = KeychainService()
//    let keychain: Keychain
//    
//   
//    private init() {
//        keychain = Keychain(service: "com.hakimAlyev.Social-Media-App-UIkit")
//    }
//    // MARK: - Keys
//       private enum Keys: String {
//           case accessToken
//           case refreshToken
//           case userID
//       }
//    
//    // MARK: - Access Token
//   
//        func saveAccessToken(_ token: String) throws {
//            try keychain.set(token, key: Keys.accessToken.rawValue)
//        }
//        
//        func getAccessToken() -> String? {
//            return try? keychain.get(Keys.accessToken.rawValue)
//        }
//    func deleteAccessToken() throws {
//            try keychain.remove(Keys.accessToken.rawValue)
//        }
//    
//    
//    // MARK: - Refresh Token
//        func saveRefreshToken(_ token: String) throws {
//            try keychain.set(token, key: Keys.refreshToken.rawValue)
//        }
//        
//        func getRefreshToken() -> String? {
//            return try? keychain.get(Keys.refreshToken.rawValue)
//        }
//        
//        func deleteRefreshToken() throws {
//            try keychain.remove(Keys.refreshToken.rawValue)
//        }
//        
//        // MARK: - User ID
//        func saveUserID(_ id: String) throws {
//            try keychain.set(id, key: Keys.userID.rawValue)
//        }
//        
//        func getUserID() -> String? {
//            return try? keychain.get(Keys.userID.rawValue)
//        }
//        
//        func deleteUserID() throws {
//            try keychain.remove(Keys.userID.rawValue)
//        }
//        
//        // MARK: - Clear All
//        func clearAll() throws {
//            try deleteAccessToken()
//            try deleteRefreshToken()
//            try deleteUserID()
//        }
//    
//}
