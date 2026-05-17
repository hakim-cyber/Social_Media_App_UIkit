//
//  RegisterScreen.swift
//  Social_Media_App_UIkitUITests
//
//  Created by aplle on 5/17/26.
//

import XCTest

final class RegisterScreen: XCTestCase {
    var app: XCUIApplication!
    var rootScreen: XCUIElement!
    var emailTextField: XCUIElement!
    var passwordTextField: XCUIElement!
    var confirmPasswordTextField: XCUIElement!
    var registerButton: XCUIElement!
    var appleSignInButton: XCUIElement!
    var googleSignInButton: XCUIElement!
    var errorLabel: XCUIElement!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append(contentsOf: [
            LaunchArgument.skipWelcome.rawValue,
            LaunchArgument.forceLoggedOut.rawValue
        ])
        
        app.launch()
        let signUp = A11y.Login.signUpButton.element(in: app)
        XCTAssert(signUp.waitForExistence(timeout: 2))
        signUp.tap()
        XCTAssert(A11y.Register.screen.element(in: app).waitForExistence(timeout: 2))

        rootScreen = A11y.Register.screen.element(in: app)
        emailTextField = A11y.Register.emailField.element(in: app)
        passwordTextField = A11y.Register.passwordField.element(in: app)
        confirmPasswordTextField = A11y.Register.confirmPasswordField.element(in: app)
        registerButton = A11y.Register.registerButtonButton.element(in: app)
        appleSignInButton = A11y.Register.appleSignInButton.element(in: app)
        googleSignInButton = A11y.Register.googleSignInButton.element(in: app)
        errorLabel = A11y.Register.errorLabel.element(in: app)
        
    }

    override func tearDownWithError() throws {
        app = nil
        rootScreen = nil
        emailTextField = nil
        passwordTextField = nil
        confirmPasswordTextField = nil
        registerButton = nil
        appleSignInButton = nil
        googleSignInButton = nil
        errorLabel = nil
    }

    func testScreenRenders() throws {
        XCTAssertTrue(A11y.Register.screen.element(in: app).waitForExistence(timeout: 2))
        XCTAssertTrue(A11y.Register.emailField.element(in: app).exists)
        XCTAssertTrue(A11y.Register.passwordField.element(in: app).exists)
        XCTAssertTrue(A11y.Register.confirmPasswordField.element(in: app).exists)
        XCTAssertTrue(A11y.Register.registerButtonButton.element(in: app).exists)
        XCTAssertTrue(A11y.Register.appleSignInButton.element(in: app).exists)
        XCTAssertTrue(A11y.Register.googleSignInButton.element(in: app).exists)
    }

    func test_register_withInvalidEmail_showsInvalidEmailError() {
        let emailTextField = A11y.Register.emailField.element(in: app)
        let passwordTextField = A11y.Register.passwordField.element(in: app)
        let confirmPasswordTextField = A11y.Register.confirmPasswordField.element(in: app)
        let registerButton = A11y.Register.registerButtonButton.element(in: app)

        emailTextField.tap()
        emailTextField.typeText("invalid_mail")

        passwordTextField.tap()
        passwordTextField.typeText("123456789")

        confirmPasswordTextField.tap()
        confirmPasswordTextField.typeText("123456789")

        registerButton.tap()

        XCTAssertTrue(A11y.Register.errorLabel.element(in: app).waitForExistence(timeout: 2))
    }

    func test_register_withMismatchedPasswords_showsError() {
        let emailTextField = A11y.Register.emailField.element(in: app)
        let passwordTextField = A11y.Register.passwordField.element(in: app)
        let confirmPasswordTextField = A11y.Register.confirmPasswordField.element(in: app)
        let registerButton = A11y.Register.registerButtonButton.element(in: app)

        emailTextField.tap()
        emailTextField.typeText("hakim5359@gmail.com")

        passwordTextField.tap()
        passwordTextField.typeText("123456789")

        confirmPasswordTextField.tap()
        confirmPasswordTextField.typeText("987654321")

        registerButton.tap()

        XCTAssertTrue(A11y.Register.errorLabel.element(in: app).waitForExistence(timeout: 2))
    }

}
