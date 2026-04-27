//
//  ForgotPasswordViewModelTests.swift
//  Social_Media_App_UIkitTests
//
//  Created by Codex on 4/26/26.
//

import Testing
@testable import Social_Media_App_UIkit

@MainActor
struct ForgotPasswordViewModelTests {

    @Test
    func test_sendPasswordReset_withInvalidEmail_setsInvalidEmailError() {
        let authService = ForgotPasswordViewModelMockAuthService()
        let sut = makeSUT(authService: authService)
        sut.email = "invalid-email"

        sut.sendPasswordReset()

        #expect(hasAuthError(sut.loginError, expected: .invalidEmail))
        #expect(sut.isLoading == false)
        #expect(authService.sendPasswordResetCallCount == 0)
    }

    @Test
    func test_sendPasswordReset_success_routesToPasswordResetConfirmAlert() async {
        let authService = ForgotPasswordViewModelMockAuthService()
        let sut = makeSUT(authService: authService)
        sut.email = "reset@mail.com"

        var routedEmail: String?
        var routedType: ConfirmAlerrType?
        sut.onRoute = { route in
            if case let .showConfirmAlert(email, type) = route {
                routedEmail = email
                routedType = type
            }
        }

        sut.sendPasswordReset()

        await assertEventually {
            routedEmail == "reset@mail.com" &&
            matchesConfirmAlertType(routedType, expected: .passwordReset) &&
            sut.isLoading == false &&
            sut.loginError?.message == nil &&
            authService.sendPasswordResetCallCount == 1
        }
    }

    @Test
    func test_changePasswordToNewOne_withShortPassword_setsTooShortError() {
        let authService = ForgotPasswordViewModelMockAuthService()
        let sut = makeSUT(authService: authService)
        sut.newPassword = "123"
        sut.confirmPassword = "123"

        sut.changePasswordToNewOne()

        #expect(hasAuthError(sut.loginError, expected: .invalidPasswordTooShort))
        #expect(sut.isLoading == false)
        #expect(authService.updatePasswordCallCount == 0)
    }

    @Test
    func test_changePasswordToNewOne_withMismatch_setsPasswordsDoNotMatchError() {
        let authService = ForgotPasswordViewModelMockAuthService()
        let sut = makeSUT(authService: authService)
        sut.newPassword = "123456"
        sut.confirmPassword = "654321"

        sut.changePasswordToNewOne()

        #expect(hasAuthError(sut.loginError, expected: .passwordsDoNotMatch))
        #expect(sut.isLoading == false)
        #expect(authService.updatePasswordCallCount == 0)
    }

    @Test
    func test_changePasswordToNewOne_success_routesToPasswordChanged() async {
        let authService = ForgotPasswordViewModelMockAuthService()
        let sut = makeSUT(authService: authService)
        sut.newPassword = "123456"
        sut.confirmPassword = "123456"

        var routedToPasswordChanged = false
        sut.onRoute = { route in
            if case .passwordChanged = route {
                routedToPasswordChanged = true
            }
        }

        sut.changePasswordToNewOne()

        await assertEventually {
            routedToPasswordChanged &&
            sut.isLoading == false &&
            sut.loginError?.message == nil &&
            authService.updatePasswordCallCount == 1
        }
    }
}
