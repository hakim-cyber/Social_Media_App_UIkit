//
//  ForgotPasswordScreen.swift
//  Social_Media_App_UIkitUITests
//
//  Created by Codex on 5/17/26.
//

import XCTest

final class ForgotPasswordScreen: XCTestCase {
    var app: XCUIApplication!
    var rootScreen: XCUIElement!
    var emailTextField: XCUIElement!
    var sendButton: XCUIElement!
    var errorLabel: XCUIElement!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append(contentsOf: [
            LaunchArgument.skipWelcome.rawValue,
            LaunchArgument.forceLoggedOut.rawValue
        ])

        app.launch()
        let forgotPassword = A11y.Login.forgotPasswordButton.element(in: app)
        XCTAssert(forgotPassword.waitForExistence(timeout: 2))
        forgotPassword.tap()
        XCTAssert(A11y.ForgotPassword.screen.element(in: app).waitForExistence(timeout: 2))

        rootScreen = A11y.ForgotPassword.screen.element(in: app)
        emailTextField = A11y.ForgotPassword.emailField.element(in: app)
        sendButton = A11y.ForgotPassword.sendButton.element(in: app)
        errorLabel = A11y.ForgotPassword.errorLabel.element(in: app)
    }

    override func tearDownWithError() throws {
        app = nil
        rootScreen = nil
        emailTextField = nil
        sendButton = nil
        errorLabel = nil
    }

    func testScreenRenders() throws {
        XCTAssertTrue(A11y.ForgotPassword.screen.element(in: app).waitForExistence(timeout: 2))
        XCTAssertTrue(A11y.ForgotPassword.emailField.element(in: app).exists)
        XCTAssertTrue(A11y.ForgotPassword.sendButton.element(in: app).exists)
    }

    func test_forgotPassword_withInvalidEmail_showsError() {
        let emailTextField = A11y.ForgotPassword.emailField.element(in: app)
        let sendButton = A11y.ForgotPassword.sendButton.element(in: app)

        emailTextField.tap()
        emailTextField.typeText("invalid_mail")

        sendButton.tap()

        XCTAssertTrue(A11y.ForgotPassword.errorLabel.element(in: app).waitForExistence(timeout: 2))
    }
}
