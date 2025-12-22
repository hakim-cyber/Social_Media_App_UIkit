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

    let tabPicker = ProfileTabPickerView()

    override init(frame: CGRect) {
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
