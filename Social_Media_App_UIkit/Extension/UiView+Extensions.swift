//
//  UiView+Extensions.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 10/5/25.
//

import UIKit

extension UIView {
    /// Resizes and pins the view to exactly match its parent view’s bounds
    func resizeToParent() {
        guard let superview = superview else { return }
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: superview.topAnchor),
            leadingAnchor.constraint(equalTo: superview.leadingAnchor),
            trailingAnchor.constraint(equalTo: superview.trailingAnchor),
            bottomAnchor.constraint(equalTo: superview.bottomAnchor)
        ])
    }
}
