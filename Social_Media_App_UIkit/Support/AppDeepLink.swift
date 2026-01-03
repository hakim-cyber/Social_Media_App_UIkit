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

        // For myapp://u/<uuid>
        // host = "u"
        // path = "/<uuid>"
        let route = url.host ?? ""
        let value = url.pathComponents.dropFirst().first // removes "/"

        switch route {
        case "account":
            // myapp://account/update-password
            if url.path.contains("update-password") {
                return .resetPassword
            }
            return .auth

        case "u":
            guard let value, let id = UUID(uuidString: value) else { return nil }
            return .profile(userId: id)


        default:
            print("none route:", route, "path:", url.path)
            return nil
        }
    }
}
