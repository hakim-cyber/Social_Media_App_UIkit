//
//  MoreSheetConfig.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 1/2/26.
//


import UIKit

struct MoreSheetConfig {
    struct Header {
        var avatar: Avatar
        var username: String
        var fullName: String?
        var isVerified: Bool = false
    }

    enum Avatar {
        case image(UIImage?)
        case url(URL?)
    }

    struct Action: Hashable {
        enum Style {
            case normal
            case primary
            case destructive
        }

        let id: String
        let title: String
        var subtitle: String? = nil
        var icon: UIImage? = nil
        var style: Style = .normal
        var isEnabled: Bool = true
        var handler: () -> Void

        func hash(into hasher: inout Hasher) { hasher.combine(id) }
        static func == (lhs: Action, rhs: Action) -> Bool { lhs.id == rhs.id }
    }

    var header: Header? = nil
    var title: String? = nil
    var message: String? = nil
    var actions: [Action] = []
}
