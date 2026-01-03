//
//  AppDeepLink.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 1/3/26.
//

import Foundation
enum AppDeepLink {
    case auth
    case resetPassword
    case profile(userId: UUID)
}
final class DeepLinkRouter {

    static func parse(url: URL) -> AppDeepLink? {
        guard url.scheme == "myapp" else { return nil }

        let host = url.host ?? ""
        let pathParts = Array(url.pathComponents.dropFirst()) // remove "/"
        let pathString = url.path

        // ✅ Handle auth callback host directly
        if host == "auth-callback" {
            // If provider sends /account/update-password
            if pathParts.contains("account") && pathParts.contains("update-password") {
                return .resetPassword
            }

            // If provider sends just myapp://auth-callback (with tokens in query/fragment)
            return .auth
        }

        // Normal routes (myapp://account/..., myapp://u/<uuid>)
        switch host {
        case "account":
            if pathParts.contains("update-password") { return .resetPassword }
            return .auth

        case "u":
            guard let first = pathParts.first, let id = UUID(uuidString: first) else { return nil }
            return .profile(userId: id)

        default:
            print("none route:", host, "path:", pathString)
            return nil
        }
    }
}
