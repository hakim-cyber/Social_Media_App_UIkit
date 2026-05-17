//
//  A11y.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 4/29/26.
//

import Foundation
struct A11y {

    struct Welcome {
        static let screen = AccessibilityItem(
            "welcome.screen",
            type: .otherElement
        )

        static let title = AccessibilityItem(
            "welcome.title",
            type: .staticText
        )

        static let subtitle = AccessibilityItem(
            "welcome.subtitle",
            type: .staticText
        )

        static let slideTrack = AccessibilityItem(
            "welcome.slideTrack",
            type: .otherElement
        )

        static let sliderThumb = AccessibilityItem(
            "welcome.sliderThumb",
            type: .otherElement
        )
    }

    struct Login {
        static let screen = AccessibilityItem(
            "login.screen",
            type: .otherElement
        )

        static let emailField = AccessibilityItem(
            "login.emailField",
            type: .textField
        )

        static let passwordField = AccessibilityItem(
            "login.passwordField",
            type: .secureTextField
        )

        static let loginButton = AccessibilityItem(
            "login.loginButton",
            type: .button
        )

        static let forgotPasswordButton = AccessibilityItem(
            "login.forgotPasswordButton",
            type: .button
        )

        static let signUpButton = AccessibilityItem(
            "login.signUpButton",
            type: .button
        )

        static let appleSignInButton = AccessibilityItem(
            "login.appleSignInButton",
            type: .otherElement
        )

        static let googleSignInButton = AccessibilityItem(
            "login.googleSignInButton",
            type: .otherElement
        )

        static let errorLabel = AccessibilityItem(
            "login.errorLabel",
            type: .staticText
        )
    }

    struct Register {
        static let screen = AccessibilityItem(
            "register.screen",
            type: .otherElement
        )

        static let emailField = AccessibilityItem(
            "register.emailField",
            type: .textField
        )

        static let passwordField = AccessibilityItem(
            "register.passwordField",
            type: .secureTextField
        )

        static let confirmPasswordField = AccessibilityItem(
            "register.confirmPasswordField",
            type: .secureTextField
        )

        static let createAccountButton = AccessibilityItem(
            "register.createAccountButton",
            type: .button
        )

        static let errorLabel = AccessibilityItem(
            "register.errorLabel",
            type: .staticText
        )
    }

    struct ForgotPassword {
        static let screen = AccessibilityItem(
            "forgotPassword.screen",
            type: .otherElement
        )

        static let emailField = AccessibilityItem(
            "forgotPassword.emailField",
            type: .textField
        )

        static let sendButton = AccessibilityItem(
            "forgotPassword.sendButton",
            type: .button
        )

        static let errorLabel = AccessibilityItem(
            "forgotPassword.errorLabel",
            type: .staticText
        )
    }
}


enum AccessibilityItemTypeForTests: CaseIterable {
    case button
    case textField
    case secureTextField
    case staticText
    case otherElement
    case image
    case collectionView
    case table
    case cell
    case switchControl
    case slider
    case scrollView
    case navigationBar
    case tabBar
    case webView
}

struct AccessibilityItem {
    let id: String
    let type: AccessibilityItemTypeForTests

    init(_ id: String, type: AccessibilityItemTypeForTests) {
        self.id = id
        self.type = type
    }
}
