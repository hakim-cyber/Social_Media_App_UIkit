//
//  LocationView.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 10/12/25.
//
import UIKit

final class LocationView: UIView {
    private let icon = UIImageView(image: UIImage(systemName: "mappin.and.ellipse"))
    private let label = UILabel()

    init(text: String?) {
        super.init(frame: .zero)
        icon.tintColor = .secondaryLabel
        icon.contentMode = .scaleAspectFit
        label.font = .systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
        label.text = text
        let stack = UIStackView(arrangedSubviews: [icon, label])
        stack.axis = .horizontal
        stack.spacing = 2
        stack.alignment = .center
        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }

    func setLocation(_ text: String?) {
        label.text = text
        isHidden = (text == nil)
    }
}
