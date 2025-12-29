//
//  ProfileTabsReusableView.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 12/22/25.
//

import Foundation
//
//  ProfileTabsReusableView.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 12/22/25.
//
import UIKit

final class ProfileTabsReusableView: UICollectionReusableView {
    static let reuseID = "ProfileTabsReusableView"
    static let kind = "profile-tabs-kind"

    let tabPicker:TabPickerView<ProfileTab>

     init(frame: CGRect,isCurrentUser:Bool) {
        self.tabPicker = TabPickerView<ProfileTab>(
            items: [
                .init(id: .posts,
                      selectedIcon: UIImage(systemName: "square.grid.2x2.fill"),
                      unselectedIcon: UIImage(systemName: "square.grid.2x2"),
                      title: "0",
                      isEnabled: true),

                .init(id: .liked,
                      selectedIcon: UIImage(systemName: "heart.fill"),
                      unselectedIcon: UIImage(systemName: "heart"),
                      title: "0",
                      isEnabled: true),

                    .init(id: .saved,
                      selectedIcon: UIImage(systemName: "bookmark.fill"),
                      unselectedIcon: UIImage(systemName: "bookmark"),
                      title: "0",
                      isEnabled: isCurrentUser,
                      disabledIcon: UIImage(systemName: "bookmark.slash"))
            ],
            selectedID: .posts
        )

        super.init(frame: frame)

        tabPicker.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tabPicker)

        NSLayoutConstraint.activate([
            tabPicker.topAnchor.constraint(equalTo: topAnchor),
            tabPicker.leadingAnchor.constraint(equalTo: leadingAnchor),
            tabPicker.trailingAnchor.constraint(equalTo: trailingAnchor),
            tabPicker.bottomAnchor.constraint(equalTo: bottomAnchor),
            tabPicker.heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    required init?(coder: NSCoder) { fatalError() }
}
