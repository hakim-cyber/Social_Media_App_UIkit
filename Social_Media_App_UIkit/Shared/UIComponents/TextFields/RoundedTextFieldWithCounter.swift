//
//  RoundedTextFieldWithCounter.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 9/30/25.
//


import UIKit
import UIKit

class InputFieldWithTitleAndCounter: UIView, UITextViewDelegate {

    private let maxCharacters: Int

    // Title label
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textColor = .label
        return label
    }()

    // Background container
    private let backgroundContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()

    // Multi-line text view
    let textView: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.font = .systemFont(ofSize: 16)
        tv.backgroundColor = .clear
        tv.isScrollEnabled = false // important for expanding
        tv.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        tv.layer.cornerRadius = 12
        return tv
    }()

    // Counter label
    private let counterLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .secondaryLabel
        return label
    }()

    // Constraint for background height
    private var containerHeightConstraint: NSLayoutConstraint!

    // Init
    init(title: String, maxCharacters: Int = 200) {
        self.maxCharacters = maxCharacters
        super.init(frame: .zero)
        titleLabel.text = title
        setupView()
        updateCounter()
    }

    required init?(coder: NSCoder) {
        self.maxCharacters = 200
        super.init(coder: coder)
        setupView()
        updateCounter()
    }

    private func setupView() {
        addSubview(titleLabel)
        addSubview(backgroundContainer)
        addSubview(counterLabel)
        backgroundContainer.addSubview(textView)

        textView.delegate = self

        // Default height
        containerHeightConstraint = backgroundContainer.heightAnchor.constraint(equalToConstant: 44)
        containerHeightConstraint.isActive = true

        NSLayoutConstraint.activate([
            // Title label
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),

            // Background container
            backgroundContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            backgroundContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundContainer.trailingAnchor.constraint(equalTo: trailingAnchor),

            // TextView inside
            textView.topAnchor.constraint(equalTo: backgroundContainer.topAnchor),
            textView.bottomAnchor.constraint(equalTo: backgroundContainer.bottomAnchor),
            textView.leadingAnchor.constraint(equalTo: backgroundContainer.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: backgroundContainer.trailingAnchor),

            // Counter label
            counterLabel.topAnchor.constraint(equalTo: backgroundContainer.bottomAnchor, constant: 4),
            counterLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            counterLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    private func updateCounter() {
        let count = textView.text.count
        counterLabel.text = "\(count)/\(maxCharacters + 1)"
        counterLabel.textColor = count > maxCharacters ? .systemRed : .secondaryLabel
    }

    // UITextViewDelegate
    func textViewDidChange(_ textView: UITextView) {
        updateCounter()

        // Limit characters
        if textView.text.count > maxCharacters {
            textView.text = String(textView.text.prefix(maxCharacters))
        }

        // Expand container height
        let size = CGSize(width: textView.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        containerHeightConstraint.constant = max(44, estimatedSize.height)
        layoutIfNeeded()
    }
}
