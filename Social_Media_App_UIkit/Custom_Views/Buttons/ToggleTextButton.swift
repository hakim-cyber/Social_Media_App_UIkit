//
//  ToggleTextButton.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 12/4/25.
//
import UIKit

final class ToggleTextButton: UIControl {

    // MARK: - UI
    private let feedback = UIImpactFeedbackGenerator(style: .light)
    let textLabel = UILabel()

    // MARK: - States
    var isToggled: Bool = false { didSet { updateAppearance(animated: true) } }
    var isLoading: Bool = false { didSet { updateAppearance(animated: true) } }

    // MARK: - Texts & colors
    var normalText: String?  { didSet { updateAppearance() } }
    var toggledText: String? { didSet { updateAppearance() } }
    var loadingText: String = "..." // You can customize this
    
    var normalColor: UIColor = .label  { didSet { updateAppearance() } }
    var toggledColor: UIColor = .label { didSet { updateAppearance() } }
    var loadingColor: UIColor = .secondaryLabel { didSet { updateAppearance() } }

    // MARK: - Callbacks
    var onToggle: ((Bool) -> Void)?
    var onTapWhileLoading: (() -> Void)? // optional if needed

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        addTarget(self, action: #selector(toggleTapped), for: .touchUpInside)
        updateAppearance()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }


    // MARK: - UI Setup
    private func setupUI() {
        isAccessibilityElement = true
        accessibilityTraits = .button

        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(textLabel)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.numberOfLines = 1
        textLabel.font = .systemFont(ofSize: 13, weight: .bold)

        NSLayoutConstraint.activate([
            textLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            textLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            textLabel.widthAnchor.constraint(equalTo: widthAnchor),
            textLabel.heightAnchor.constraint(equalTo: heightAnchor),
        ])
    }

    // MARK: - Tap Action
    @objc private func toggleTapped() {
        guard !isLoading else {
            onTapWhileLoading?()
            return
        }

        isToggled.toggle()
        feedback.impactOccurred()
        onToggle?(isToggled)
        sendActions(for: .valueChanged)
    }

    // MARK: - Update UI for State Changes
    private func updateAppearance(animated: Bool = false) {
        
        let newText: String
        let newColor: UIColor

        if isLoading {
            newText = loadingText
            newColor = loadingColor
        } else {
            newText = isToggled ? (toggledText ?? "") : (normalText ?? "")
            newColor = isToggled ? toggledColor : normalColor
        }

        let applyChanges = {
            self.textLabel.text = newText
            self.textLabel.textColor = newColor
            self.isUserInteractionEnabled = !self.isLoading
        }

        if animated {
            UIView.transition(
                with: textLabel,
                duration: 0.2,
                options: .transitionCrossDissolve,
                animations: applyChanges
            )
        } else {
            applyChanges()
        }
    }
}
