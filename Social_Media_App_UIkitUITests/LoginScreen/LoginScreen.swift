//
//  LoginScreen.swift
//  Social_Media_App_UIkitUITests
//
//  Created by aplle on 5/16/26.
//

import XCTest

final class LoginScreen: XCTestCase {
    var app: XCUIApplication!
    var rootScreen:XCUIElement!
    var emailTextField:XCUIElement!
    var passwordTextField:XCUIElement!
    var loginButton:XCUIElement!
    var forgotPasswordButton:XCUIElement!
    var signUpButton:XCUIElement!
    var appleSignInButton:XCUIElement!
    var googleSignInButton:XCUIElement!
  
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append(contentsOf: [LaunchArgument.skipWelcome.rawValue,LaunchArgument.forceLoggedOut.rawValue])
        
        app.launch()
        rootScreen = A11y.Login.screen.element(in: app)
        emailTextField =  A11y.Login.emailField.element(in: app)
        passwordTextField =  A11y.Login.passwordField.element(in: app)
        loginButton =  A11y.Login.loginButton.element(in: app)
        forgotPasswordButton = A11y.Login.forgotPasswordButton.element(in: app)
        signUpButton =  A11y.Login.signUpButton.element(in: app)
        appleSignInButton =  A11y.Login.appleSignInButton.element(in: app)
        googleSignInButton =  A11y.Login.googleSignInButton.element(in: app)
    }
    
    override func tearDownWithError() throws {
        app = nil
       rootScreen = nil
       emailTextField = nil
       passwordTextField = nil
       loginButton = nil
       forgotPasswordButton = nil
       signUpButton = nil
       appleSignInButton = nil
       googleSignInButton = nil
    }
    
    func testScreenRenders() throws {
        XCTAssertTrue( A11y.Login.screen.element(in: app).waitForExistence(timeout: 2))
        XCTAssertTrue(A11y.Login.emailField.element(in: app).exists)
        XCTAssertTrue(A11y.Login.passwordField.element(in: app).exists)
        XCTAssertTrue(A11y.Login.loginButton.element(in: app).exists)
        XCTAssertTrue(A11y.Login.forgotPasswordButton.element(in: app).exists)
        XCTAssertTrue(A11y.Login.signUpButton.element(in: app).exists)
        XCTAssertTrue(A11y.Login.appleSignInButton.element(in: app).exists)
        XCTAssertTrue(A11y.Login.googleSignInButton.element(in: app).exists)
        
        
        
    }
    func test_login_withInvalidEmail_showsInvalidEmailError(){
        let emailTextField = A11y.Login.emailField.element(in: app)
        let passwordTextField = A11y.Login.passwordField.element(in: app)
        let loginButton = A11y.Login.loginButton.element(in: app)
        
        emailTextField.tap()
        emailTextField.typeText("invalid_mail")
        
        passwordTextField.tap()
        passwordTextField.typeText("123456789")
        
        loginButton.tap()
        
        XCTAssertTrue(A11y.Login.errorLabel.element(in: app).waitForExistence(timeout: 2))
    }
    func test_emptyPassword_showsEmptylError(){
        let emailTextField = A11y.Login.emailField.element(in: app)
        let passwordTextField = A11y.Login.passwordField.element(in: app)
        let loginButton = A11y.Login.loginButton.element(in: app)
        
        
        emailTextField.tap()
        emailTextField.typeText("hakim5359@gmail.com")
        
        passwordTextField.tap()
        passwordTextField.typeText("")
        
        loginButton.tap()
        
        XCTAssertTrue(A11y.Login.errorLabel.element(in: app).waitForExistence(timeout: 2))
    }
    func test_login_tappingSignUp_opensRegisterScreen(){
        A11y.Login.signUpButton.element(in: app).tap()
        XCTAssertTrue(A11y.Register.screen.element(in: app).waitForExistence(timeout: 2))
    }
    func test_login_tappingForgotPassword_opensForgotPasswordScreen(){
        A11y.Login.forgotPasswordButton.element(in: app).tap()
        XCTAssertTrue(A11y.ForgotPassword.screen.element(in: app).waitForExistence(timeout: 2))
    }
   
}
