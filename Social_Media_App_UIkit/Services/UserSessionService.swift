//
//  UserSessionService.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 9/20/25.
//
import Foundation

final class UserSessionService {
    static let shared = UserSessionService()
    private init() {}
    
//    private(set) var currentUser: User?
//    
//    func setCurrentUser(_ user: User) {
//        self.currentUser = user
//        CoreDataService.shared.saveUser(user)
//    }
//    
//    func loadFromCache() {
//        if let cached = CoreDataService.shared.fetchUser() {
//            self.currentUser = cached
//        }
//    }
//    
//    func clearSession() {
//        self.currentUser = nil
//        CoreDataService.shared.deleteUser()
//    }
}
