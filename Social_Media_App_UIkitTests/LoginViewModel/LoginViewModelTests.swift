//
//  LoginViewModelTests.swift
//  Social_Media_App_UIkitTests
//
//  Created by Codex on 4/26/26.
//

import Testing
import UIKit
@testable import Social_Media_App_UIkit

@MainActor
struct LoginViewModelTests {

    @Test
    func test_login_withInvalidEmail_setsInvalidEmailError() {
        let authService = LoginViewModelMockAuthService()
        let sut = makeSUT(authService: authService)
        sut.email = "invalid-email"
        sut.password = "123456"

        sut.login()

        #expect(hasAuthError(sut.loginError, expected: .invalidEmail))
        #expect(sut.isLoading == false)
        #expect(authService.signInCallCount == 0)
    }

    @Test
    func test_login_withEmptyPassword_setsEmptyPasswordError() {
        let authService = LoginViewModelMockAuthService()
        let sut = makeSUT(authService: authService)
        sut.email = "test@mail.com"
        sut.password = ""

        sut.login()

        #expect(hasAuthError(sut.loginError, expected: .invalidPasswordEmpty))
        #expect(sut.isLoading == false)
        #expect(authService.signInCallCount == 0)
    }

    @Test
    func test_login_withShortPassword_setsPasswordTooShortError() {
        let authService = LoginViewModelMockAuthService()
        let sut = makeSUT(authService: authService)
        sut.email = "test@mail.com"
        sut.password = "123"

        sut.login()

        #expect(hasAuthError(sut.loginError, expected: .invalidPasswordTooShort))
        #expect(sut.isLoading == false)
        #expect(authService.signInCallCount == 0)
    }

    @Test
    func test_login_success_clearsError_andStopsLoading() async {
        let authService = LoginViewModelMockAuthService()
        authService.signInResult = .success(makeUser(email: "test@mail.com"))

        let sut = makeSUT(authService: authService)
        sut.loginError = .invalidEmail
        sut.email = "test@mail.com"
        sut.password = "123456"

        sut.login()

        await assertEventually {
            sut.loginError?.message == nil &&
            sut.isLoading == false &&
            authService.signInCallCount == 1 &&
            authService.receivedEmail == "test@mail.com" &&
            authService.receivedPassword == "123456"
        }
    }

    @Test
    func test_login_failure_mapsAuthError_andStopsLoading() async {
        let authService = LoginViewModelMockAuthService()
        authService.signInResult = .failure(AuthError.wrongPassword)

        let sut = makeSUT(authService: authService)
        sut.email = "test@mail.com"
        sut.password = "123456"

        sut.login()

        await assertEventually {
            hasAuthError(sut.loginError, expected: .wrongPassword) &&
            sut.isLoading == false &&
            authService.signInCallCount == 1
        }
    }

    @Test
    func test_login_failure_mapsUnknownErrorThroughMapSupabaseError() async {
        let authService = LoginViewModelMockAuthService()
        authService.signInResult = .failure(LoginViewModelTestError("Network request failed"))

        let sut = makeSUT(authService: authService)
        sut.email = "test@mail.com"
        sut.password = "123456"

        sut.login()

        await assertEventually {
            hasAuthError(sut.loginError, expected: .networkError) &&
            sut.isLoading == false
        }
    }

    @Test
    func test_forgotPassword_routesWithCurrentEmail() {
        let sut = makeSUT()
        sut.email = "route@mail.com"

        var routedEmail: String?
        sut.onRoute = { route in
            if case let .forgotPassword(email) = route {
                routedEmail = email
            }
        }

        sut.forgotPassword()

        #expect(routedEmail == "route@mail.com")
    }

    @Test
    func test_goToSignUp_routesWithCurrentEmail() {
        let sut = makeSUT()
        sut.email = "signup@mail.com"

        var routedEmail: String?
        sut.onRoute = { route in
            if case let .signUp(email) = route {
                routedEmail = email
            }
        }

        sut.goToSignUP()

        #expect(routedEmail == "signup@mail.com")
    }

    @Test
    func test_signInWithGoogle_success_clearsError_andStopsLoading() async {
        let socialAuthService = LoginViewModelMockSocialAuthService()
        socialAuthService.googleResult = .success(makeUser(email: "google@mail.com"))

        let sut = makeSUT(socialAuthService: socialAuthService)
        sut.loginError = .invalidEmail

        sut.signInWithGoogle(viewController: UIViewController())

        await assertEventually {
            sut.loginError?.message == nil &&
            sut.isLoading == false &&
            socialAuthService.googleSignInCallCount == 1
        }
    }

    @Test
    func test_signInWithGoogle_failure_setsMappedError_andStopsLoading() async {
        let socialAuthService = LoginViewModelMockSocialAuthService()
        socialAuthService.googleResult = .failure(LoginViewModelTestError("network timeout"))

        let sut = makeSUT(socialAuthService: socialAuthService)

        sut.signInWithGoogle(viewController: UIViewController())

        await assertEventually {
            hasAuthError(sut.loginError, expected: .networkError) &&
            sut.isLoading == false &&
            socialAuthService.googleSignInCallCount == 1
        }
    }
}
