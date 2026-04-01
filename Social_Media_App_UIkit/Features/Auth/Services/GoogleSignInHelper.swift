 //
//  GoogleSignInHelper.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 9/25/25.
//

import UIKit
import GoogleSignIn

@MainActor
protocol GoogleSignInFlowPerforming {
    func start(from viewController: UIViewController) async throws -> String
}

@MainActor
final class GoogleSignInHelper: NSObject, GoogleSignInFlowPerforming {

    func start(from viewController: UIViewController) async throws -> String {

        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: viewController)

        guard let idToken = result.user.idToken?.tokenString else {
            throw AuthError.userNotFound
        }

        return idToken
    }
}
