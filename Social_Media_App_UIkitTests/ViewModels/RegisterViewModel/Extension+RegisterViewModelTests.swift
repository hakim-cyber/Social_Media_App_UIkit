//
//  Extension+RegisterViewModelTests.swift
//  Social_Media_App_UIkitTests
//
//  Created by Codex on 4/26/26.
//

import Foundation
import Supabase
import Testing
@testable import Social_Media_App_UIkit

extension RegisterViewModelTests {
    @MainActor
    func makeSUT(
        authService: RegisterViewModelMockAuthService? = nil,
        socialAuthService: RegisterViewModelMockSocialAuthService? = nil
    ) -> RegisterViewModel {
        let authService: RegisterViewModelMockAuthService = authService ?? .init()
        let socialAuthService: RegisterViewModelMockSocialAuthService = socialAuthService ?? .init()
      return  RegisterViewModel(
            authService: authService,
            socialAuthService: socialAuthService
        )
    }

    func makeUser(
        id: UUID = UUID(),
        email: String = "register@mail.com"
    ) -> User {
        User(
            id: id,
            appMetadata: [:],
            userMetadata: [:],
            aud: "authenticated",
            email: email,
            createdAt: .now,
            updatedAt: .now
        )
    }

    func assertEventually(
        timeout: TimeInterval = 1.0,
        interval: TimeInterval = 0.02,
        _ condition: @escaping () -> Bool
    ) async {
        let deadline = Date().addingTimeInterval(timeout)

        while Date() < deadline {
            if condition() {
                #expect(true)
                return
            }

            try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
        }

        #expect(Bool(false))
    }

    func hasAuthError(_ received:Social_Media_App_UIkit.AuthError?, expected: Social_Media_App_UIkit.AuthError) -> Bool {
        received?.title == expected.title &&
        received?.message == expected.message
    }

    func matchesConfirmAlertType(
        _ received: ConfirmAlerrType?,
        expected: ConfirmAlerrType
    ) -> Bool {
        switch (received, expected) {
        case (.passwordReset, .passwordReset), (.emailVerification, .emailVerification):
            return true
        default:
            return false
        }
    }
}
