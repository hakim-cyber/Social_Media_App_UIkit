//
//  Extension+ForgotPasswordViewModelTests.swift
//  Social_Media_App_UIkitTests
//
//  Created by Codex on 4/26/26.
//

import Foundation
import Testing
@testable import Social_Media_App_UIkit

extension ForgotPasswordViewModelTests {
    @MainActor
    func makeSUT(
        authService: ForgotPasswordViewModelMockAuthService? = nil
    ) -> ForgotPasswordViewModel {
        let authService = authService ?? .init()
      return  ForgotPasswordViewModel(authService: authService)
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

    func hasAuthError(_ received: AuthError?, expected: AuthError) -> Bool {
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
