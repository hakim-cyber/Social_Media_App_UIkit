//
//  LocationSelectButton.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 10/5/25.
//

import Foundation
import UIKit

final class LocationPickerButton: UIControl {

    // MARK: Public API
    var placeholder: String = "Add location" { didSet { updateLabels() } }
    var locationText: String? { didSet { updateLabels() } }
    var onTap: (() -> Void)?
    var onClear: (() -> Void)?

    // MARK: UI
    private let container = UIView()
    private let iconView = UIImageView(image: UIImage(systemName: "mappin.and.ellipse"))
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let labelsStack = UIStackView()
    private let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
    private let clearButton = UIButton(type: .system)

    // MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        isUserInteractionEnabled = true
        accessibilityTraits = [.button]
        backgroundColor = .clear

        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .secondarySystemBackground
        container.layer.cornerRadius = 14
        container.layer.masksToBounds = true
        addSubview(container)

        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = .label

        titleLabel.font = .systemFont(ofSize: 15, weight: .medium)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 1

        subtitleLabel.font = .systemFont(ofSize: 12, weight: .regular)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 1
        subtitleLabel.isHidden = true

        labelsStack.translatesAutoresizingMaskIntoConstraints = false
        labelsStack.axis = .vertical
        labelsStack.spacing = 2
        labelsStack.addArrangedSubview(titleLabel)
        labelsStack.addArrangedSubview(subtitleLabel)

        chevron.translatesAutoresizingMaskIntoConstraints = false
        chevron.contentMode = .scaleAspectFit
        chevron.tintColor = .tertiaryLabel

        clearButton.translatesAutoresizingMaskIntoConstraints = false
        clearButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        clearButton.tintColor = .tertiaryLabel
        clearButton.isHidden = true
        clearButton.addTarget(self, action: #selector(clearTapped), for: .touchUpInside)

        [iconView, labelsStack, chevron, clearButton].forEach { container.addSubview($0) }

        // Layout
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: topAnchor),
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor),
            container.bottomAnchor.constraint(equalTo: bottomAnchor),

            iconView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            iconView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 18),
            iconView.heightAnchor.constraint(equalToConstant: 18),

            chevron.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -10),
            chevron.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            chevron.widthAnchor.constraint(equalToConstant: 12),
            chevron.heightAnchor.constraint(equalToConstant: 18),

            clearButton.trailingAnchor.constraint(equalTo: chevron.leadingAnchor, constant: -6),
            clearButton.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            clearButton.widthAnchor.constraint(equalToConstant: 24),
            clearButton.heightAnchor.constraint(equalToConstant: 24),

            labelsStack.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 10),
            labelsStack.trailingAnchor.constraint(lessThanOrEqualTo: clearButton.leadingAnchor, constant: -8),
            labelsStack.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            labelsStack.topAnchor.constraint(greaterThanOrEqualTo: container.topAnchor, constant: 8),
            labelsStack.bottomAnchor.constraint(lessThanOrEqualTo: container.bottomAnchor, constant: -8),

            container.heightAnchor.constraint(greaterThanOrEqualToConstant: 44)
        ])

        // Tap gesture over entire control
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTap))
        addGestureRecognizer(tap)

        updateLabels()
    }

    private func updateLabels() {
        if let text = locationText, !text.isEmpty {
            // If you ever want a 2-line style, split here:
            // let parts = text.split(separator: ",", maxSplits: 1).map(String.init)
            titleLabel.text = text
            subtitleLabel.isHidden = true // set false if you pass a separate subtitle
            clearButton.isHidden = false
            accessibilityLabel = "Location: \(text)"
        } else {
            titleLabel.text = placeholder
            subtitleLabel.isHidden = true
            clearButton.isHidden = true
            accessibilityLabel = "Add location"
        }
    }

    @objc private func didTap() {
        UISelectionFeedbackGenerator().selectionChanged()
        onTap?()
        sendActions(for: .primaryActionTriggered)
    }

    @objc private func clearTapped() {
        locationText = nil
        onClear?()
        sendActions(for: .valueChanged)
    }
}
