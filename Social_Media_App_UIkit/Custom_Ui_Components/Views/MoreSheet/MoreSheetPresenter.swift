//
//  MoreSheetPresenter.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 1/2/26.
//

import UIKit
import Supabase
enum MoreSheetPresenter {

    static func present(config: MoreSheetConfig, from vc: UIViewController) {
        let sheetVC = MoreSheetViewController(config: config)
        let nav = UINavigationController(rootViewController: sheetVC)
        nav.modalPresentationStyle = .pageSheet

        if let sheet = nav.sheetPresentationController {

            let id = UISheetPresentationController.Detent.Identifier("fit")

            // compute ONCE before presenting
            let wanted = sheetVC.estimatedSheetHeight()
            let cap = UIScreen.main.bounds.height * 0.85
            let finalHeight = min(wanted, cap)

            let fit = UISheetPresentationController.Detent.custom(identifier: id) { ctx in
                min(finalHeight, ctx.maximumDetentValue)
            }

            // if too tall -> allow large for scrolling
            sheet.detents = (wanted > cap) ? [fit, .large()] : [fit]
            sheet.selectedDetentIdentifier = id
            sheet.prefersGrabberVisible = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
        }

        vc.present(nav, animated: true)
    }
}

extension MoreSheetPresenter {

    static func showPost(
        _ post: Post,
        from vc: UIViewController,
        onSave: (() -> Void)? = nil,
        onCopy: (() -> Void)? = nil,
        onReport: (() -> Void)? = nil,
        onDelete: (() -> Void)? = nil
    ) {

        let header = MoreSheetConfig.Header(
            avatar: .url(post.author.avatarURL),
            username: post.author.username,
            fullName: nil,
            isVerified: post.author.isVerified
        )

        var actions: [MoreSheetConfig.Action] = []

        actions.append(
            .init(
                id: "save",
                title: post.isSaved ? "Remove from saved" : "Save post",
                subtitle: "Save to look later",
                icon: UIImage(systemName: post.isSaved ? "bookmark.slash" : "bookmark.fill"),
                style: .normal,
                isEnabled: true,
                handler: { onSave?() }
            )
        )

        actions.append(
            .init(
                id: "copy",
                title: "Copy link",
                subtitle: "Share with your friends",
                icon: UIImage(systemName: "link"),
                style: .normal,
                isEnabled: true,
                handler: { onCopy?() }
            )
        )

        actions.append(
            .init(
                id: "report",
                title: "Report",
                subtitle: "This will notify moderators",
                icon: UIImage(systemName: "exclamationmark.bubble"),
                style: .destructive,
                isEnabled: true,
                handler: { onReport?() }
            )
        )

        // Owner-only action
        if post.author.id == UserSessionService.shared.currentUser?.id {
            actions.append(
                .init(
                    id: "delete",
                    title: "Delete post",
                    subtitle: "This will delete post permanently",
                    icon: UIImage(systemName: "trash.fill"),
                    style: .destructive,
                    isEnabled: true,
                    handler: { onDelete?() }
                )
            )
        }

        let config = MoreSheetConfig(
            header: header,
            title: nil,
            message: nil,
            actions: actions
        )

        present(config: config, from: vc)
    }
    static func showFollower(
        _ user: UserFollowItem,
        from vc: UIViewController,
        onDelete: (() -> Void)? = nil
    ) {

        let header = MoreSheetConfig.Header(
            avatar: .url(user.avatarURL),
            username: "",
            fullName: nil,
            isVerified:false
        )

        var actions: [MoreSheetConfig.Action] = []

        // Owner-only action
        
            actions.append(
                .init(
                    id: "remove",
                    title: "Remove",
                    subtitle: "",
                    icon: UIImage(systemName: "trash.fill"),
                    style: .destructive,
                    isEnabled: true,
                    handler: { onDelete?() }
                )
            )
        

        let config = MoreSheetConfig(
            header: header,
            title: "Remove follower?",
            message: "We won't tell \(user.username) they were removed from your followers.",
            actions: actions
        )

        present(config: config, from: vc)
    }
    static func showProfile(
        _ user: UserProfile,
        from vc: UIViewController,
        onLogOut: (() -> Void)? = nil
    ) {
        let header = MoreSheetConfig.Header(
            avatar: .url(URL(string: user.avatar_url ?? "")),
            username: user.username,
            fullName: user.full_name,
            isVerified: user.is_verified ?? false
        )

        let actions: [MoreSheetConfig.Action] = [
            .init(
                id: "logout",
                title: "Log out",
                subtitle: "You can log back in anytime.",
                icon: UIImage(systemName: "rectangle.portrait.and.arrow.right"),
                style: .destructive,
                isEnabled: true,
                handler: { onLogOut?() }
            )
        ]

        let config = MoreSheetConfig(
            header: header,
            title: "Log out of Aura?",
            message: "You’ll need to sign in again to access your account.",
            actions: actions
        )

        present(config: config, from: vc)
    }

}
