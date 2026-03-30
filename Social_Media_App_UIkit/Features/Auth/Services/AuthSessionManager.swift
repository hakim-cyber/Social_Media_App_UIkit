//
//  AuthSessionManager.swift
//  Social_Media_App_UIkit
//
//  Created by Codex on 3/31/26.
//

import Foundation

protocol SessionManaging {
    func logout() async throws
}

struct AuthSessionManager: SessionManaging {
    func logout() async throws {
        try await AuthService.shared.logout()
    }
}
