//
//  ToggleButton.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 10/14/25.
//


import UIKit
final class ToggleButton: UIControl {
    private let imageView = UIImageView()
    private let feedback = UIImpactFeedbackGenerator(style: .light)

    var isToggled: Bool = false { didSet { updateAppearance(animated: true) } }
    var normalImage: UIImage?  { didSet { updateAppearance() } }
    var toggledImage: UIImage? { didSet { updateAppearance() } }
    var normalColor: UIColor = .systemGray { didSet { updateAppearance() } }
    var toggledColor: UIColor = .systemRed  { didSet { updateAppearance() } }
    var onToggle: ((Bool) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        addTarget(self, action: #selector(toggle), for: .touchUpInside)
        updateAppearance() // render immediately
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupUI() {
        isAccessibilityElement = true
        accessibilityTraits = .button

        translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit

        NSLayoutConstraint.activate([
            // ensure the control has a tap area even if no external constraints
            widthAnchor.constraint(greaterThanOrEqualToConstant: 44),
            heightAnchor.constraint(greaterThanOrEqualToConstant: 44),

            // center the icon and give it explicit size
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 24),
            imageView.heightAnchor.constraint(equalToConstant: 24),
        ])
    }

    @objc private func toggle() {
        isToggled.toggle()
        feedback.impactOccurred()
        onToggle?(isToggled)
        sendActions(for: .valueChanged)
        animateBounce()
    }

    private func updateAppearance(animated: Bool = false) {
        let img  = (isToggled ? toggledImage : normalImage)?.withRenderingMode(.alwaysTemplate)
        let tint = isToggled ? toggledColor : normalColor
        let apply = {
            self.imageView.image = img
            self.imageView.tintColor = tint
        }
        animated
        ? UIView.transition(with: imageView, duration: 0.2, options: .transitionCrossDissolve, animations: apply)
        : apply()
    }

    private func animateBounce() {
        imageView.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        UIView.animate(withDuration: 0.28, delay: 0,
                       usingSpringWithDamping: 0.45, initialSpringVelocity: 0.4,
                       options: [.allowUserInteraction],
                       animations: { self.imageView.transform = .identity })
    }
}
