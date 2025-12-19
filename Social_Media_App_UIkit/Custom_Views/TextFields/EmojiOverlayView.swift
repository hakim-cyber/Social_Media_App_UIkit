//
//  EmojiOverlayView.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 12/19/25.
//

import UIKit

final class EmojiOverlayView: UIView {

    var onEmojiTap: ((String) -> Void)?

    private let emojis = ["❤️" , "😂", "😍", "🔥", "😀","👏", "😢", "😡"]

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        self.translatesAutoresizingMaskIntoConstraints = false
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .center
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false

        emojis.forEach { emoji in
            let btn = UIButton(type: .system)
            btn.setTitle(emoji, for: .normal)
            btn.titleLabel?.font = .systemFont(ofSize: 26)
            btn.addAction(UIAction { [weak self] _ in
                self?.onEmojiTap?(emoji)
            }, for: .touchUpInside)
            stack.addArrangedSubview(btn)
        }

        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}
