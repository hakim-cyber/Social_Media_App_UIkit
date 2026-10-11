//
//  RegisterViewModelTests.swift
//  Social_Media_App_UIkitTests
//
//  Created by Codex on 4/26/26.
//

import Testing
import UIKit
@testable import Social_Media_App_UIkit

@MainActor
struct RegisterViewModelTests {

    @Test
    func test_signUp_withInvalidEmail_setsInvalidEmailError() {
        let authService = RegisterViewModelMockAuthService()
        let sut = makeSUT(authService: authService)
        sut.email = "invalid-email"
        sut.password = "123456"
        sut.confirmPassword = "123456"

        sut.signUp()

        #expect(hasAuthError(sut.loginError, expected: .invalidEmail))
        #expect(sut.isLoading == false)
        #expect(authService.signUpCallCount == 0)
    }

    @Test
    func test_signUp_withPasswordsDoNotMatch_setsPasswordsDoNotMatchError() {
        let authService = RegisterViewModelMockAuthService()
        let sut = makeSUT(authService: authService)
        sut.email = "test@mail.com"
        sut.password = "123456"
        sut.confirmPassword = "654321"

        sut.signUp()

        #expect(hasAuthError(sut.loginError, expected: .passwordsDoNotMatch))
        #expect(sut.isLoading == false)
        #expect(authService.signUpCallCount == 0)
    }

    @Test
    func test_signUp_success_routesToEmailVerificationAndStopsLoading() async {
        let authService = RegisterViewModelMockAuthService()
        authService.signUpResult = .success(makeUser(email: "register@mail.com"))
        let sut = makeSUT(authService: authService)
        sut.email = "register@mail.com"
        sut.password = "123456"
        sut.confirmPassword = "123456"

        var routedEmail: String?
        var routedType: ConfirmAlerrType?
        sut.onRoute = { route in
            if case let .showConfirmAlert(email, type) = route {
                routedEmail = email
                routedType = type
            }
        }

        sut.signUp()

        await assertEventually {
            routedEmail == "register@mail.com" &&
            matchesConfirmAlertType(routedType, expected: .emailVerification) &&
            sut.isLoading == false &&
            sut.loginError?.message == nil &&
            authService.signUpCallCount == 1
        }
    }

    @Test
    func test_signUp_failure_mapsAuthError_andStopsLoading() async {
        let authService = RegisterViewModelMockAuthService()
        authService.signUpResult = .failure(AuthError.emailAlreadyRegistered)
        let sut = makeSUT(authService: authService)
        sut.email = "register@mail.com"
        sut.password = "123456"
        sut.confirmPassword = "123456"

        sut.signUp()

        await assertEventually {
            hasAuthError(sut.loginError, expected: .emailAlreadyRegistered) &&
            sut.isLoading == false &&
            authService.signUpCallCount == 1
        }
    }

    @Test
    func test_signInWithGoogle_failure_setsMappedError_andStopsLoading() async {
        let socialAuthService = RegisterViewModelMockSocialAuthService()
        socialAuthService.googleResult = .failure(RegisterViewModelTestError("network timeout"))
        let sut = makeSUT(socialAuthService: socialAuthService)

        sut.signInWithGoogle(viewController: UIViewController())

        await assertEventually {
            hasAuthError(sut.loginError, expected: .networkError) &&
            sut.isLoading == false &&
            socialAuthService.googleSignInCallCount == 1
        }
    }
}
