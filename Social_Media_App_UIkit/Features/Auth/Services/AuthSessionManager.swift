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
    private let authService: any AuthServicing

    init(authService: any AuthServicing) {
        self.authService = authService
    }

    func logout() async throws {
        try await authService.logout()
    }
}
