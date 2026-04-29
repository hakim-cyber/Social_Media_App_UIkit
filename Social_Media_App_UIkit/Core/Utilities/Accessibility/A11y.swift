//
//  A11y.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 4/29/26.
//

import Foundation

struct A11y {
    struct Welcome {
        static let screen = "welcome.screen"
        static let title = "welcome.title"
        static let subtitle = "welcome.subtitle"
        static let slideTrack = "welcome.slideTrack"
        static let sliderThumb = "welcome.sliderThumb"
    }

    struct Login {
        static let screen = "login.screen"
        static let emailField = "login.emailField"
        static let passwordField = "login.passwordField"
        static let loginButton = "login.loginButton"
        static let forgotPasswordButton = "login.forgotPasswordButton"
        static let signUpButton = "login.signUpButton"
        static let errorLabel = "login.errorLabel"
    }

    struct Register {
        static let screen = "register.screen"
        static let emailField = "register.emailField"
        static let passwordField = "register.passwordField"
        static let confirmPasswordField = "register.confirmPasswordField"
        static let createAccountButton = "register.createAccountButton"
        static let errorLabel = "register.errorLabel"
    }

    struct ForgotPassword {
        static let screen = "forgotPassword.screen"
        static let emailField = "forgotPassword.emailField"
        static let sendButton = "forgotPassword.sendButton"
        static let errorLabel = "forgotPassword.errorLabel"
    }
}
