//
//  AuthService.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 9/20/25.
//

import Foundation

final class AuthService {
    static let shared = AuthService()
    private init() {}

    private let keychain = KeychainService.shared

//    var isLoggedIn: Bool {
//        return keychain.getToken() != nil
//    }
//
//    func login(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
//        SupabaseClient.shared.auth.signIn(email: email, password: password) { result in
//            switch result {
//            case .success(let session):
//                self.keychain.saveToken(session.accessToken)
//                completion(.success(session.user))
//            case .failure(let error):
//                completion(.failure(error))
//            }
//        }
//    }
//
//    func register(username: String, email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
//        SupabaseClient.shared.auth.signUp(email: email, password: password) { result in
//            completion(result)
//        }
//    }
//
//    func logout() {
//        keychain.clear()
//    }
}
