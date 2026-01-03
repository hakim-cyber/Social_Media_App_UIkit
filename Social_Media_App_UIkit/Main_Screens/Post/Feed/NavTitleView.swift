//
//  NavTitleView.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 1/3/26.
//
import UIKit

final class NavTitleView: UIView {

    private let titleLabel = UILabel()

    init(title: String) {
        super.init(frame: .zero)
        setup(title: title)
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setup(title: String) {
        titleLabel.text = title
        titleLabel.font = UIFont(name: "LobsterTwo-Bold", size: 28) ?? .boldSystemFont(ofSize: 28)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center

        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
}
