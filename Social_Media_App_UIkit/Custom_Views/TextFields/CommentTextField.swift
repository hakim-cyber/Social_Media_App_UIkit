//
//  CommentTextField.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 12/19/25.
//

import UIKit
import UIKit

final class CommentTextField: UIView {

    // MARK: - Public API
    var onSend: ((String) -> Void)?
    func emptyText() {
        textView.text = ""
        placeholderLabel.isHidden = false
        updateSendState()
        updateTextViewHeight()
    }

    // MARK: - UI
    private let containerView: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        v.layer.borderWidth = 0.5
        v.layer.borderColor = UIColor.gray.withAlphaComponent(0.2).cgColor
        v.layer.cornerRadius = 22
        v.isUserInteractionEnabled = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let textView: UITextView = {
        let tv = UITextView()
        tv.font = .systemFont(ofSize: 16)
        tv.backgroundColor = .clear
        tv.isScrollEnabled = false                       // ✅ auto-grow
        tv.textContainerInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        tv.textContainer.lineFragmentPadding = 0         // ✅ aligns like UITextField
        tv.returnKeyType = .default                      // keep default; send is via button
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    private let placeholderLabel: UILabel = {
        let l = UILabel()
        l.text = "What do you think?"
        l.textColor = .secondaryLabel
        l.font = .systemFont(ofSize: 16)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    let sendButton = CustomImageButton(
        backgroundColor: .electricPurple,
        systemImage: "arrow.up",
        cornerRadius: 16
    )

    // MARK: - Layout constraints
    private var textViewHeightConstraint: NSLayoutConstraint!
    private let minTextViewHeight: CGFloat = 34
    private let maxTextViewHeight: CGFloat = 120

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        setupUI()
        setupActions()
        setupTapToFocus()
        updateSendState()
        updateTextViewHeight()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Setup
    private func setupUI() {
        addSubview(containerView)
        containerView.addSubview(textView)
        containerView.addSubview(sendButton)
        textView.addSubview(placeholderLabel)

        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.isHidden = true
        sendButton.isUserInteractionEnabled = false

        textView.delegate = self

        textViewHeightConstraint = textView.heightAnchor.constraint(greaterThanOrEqualToConstant: minTextViewHeight)
        textViewHeightConstraint.isActive = true

        NSLayoutConstraint.activate([
            // container
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            containerView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),

            // ✅ minimum height for whole component
            heightAnchor.constraint(greaterThanOrEqualToConstant: 46),

            // send button
            sendButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            sendButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8),
            sendButton.widthAnchor.constraint(equalToConstant: 56),
            sendButton.heightAnchor.constraint(equalToConstant: 30),

            // text view
            textView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 14),
            textView.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -10),
            textView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 5.5),
            textView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -5.5),
            
           

            // placeholder inside textView
            placeholderLabel.leadingAnchor.constraint(equalTo: textView.leadingAnchor),
            placeholderLabel.topAnchor.constraint(equalTo: textView.topAnchor, constant: 10),
            placeholderLabel.trailingAnchor.constraint(lessThanOrEqualTo: textView.trailingAnchor)
        ])
    }

    private func setupActions() {
        sendButton.tapAction = { [weak self] in
            self?.sendTapped()
        }
    }
    func insertEmoji(_ emoji: String) {
        textView.insertText(emoji)
    }
    private func setupTapToFocus() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(containerTapped))
        containerView.addGestureRecognizer(tap)
    }

    // MARK: - Actions
    @objc private func containerTapped() {
        textView.becomeFirstResponder()
    }

    private func sendTapped() {
        let text = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        onSend?(text)
        // call emptyText() from VC when your request succeeds
    }

    private func updateSendState() {
        let hasText = !textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        sendButton.isHidden = !hasText
        sendButton.isUserInteractionEnabled = hasText
        placeholderLabel.isHidden = hasText
    }

    private func updateTextViewHeight() {
        let targetWidth = textView.bounds.width
        guard targetWidth > 0 else { return }

        let fittingSize = CGSize(width: targetWidth, height: .greatestFiniteMagnitude)
        let measured = textView.sizeThatFits(fittingSize).height

        let clamped = min(max(measured, minTextViewHeight), maxTextViewHeight)
        textViewHeightConstraint.constant = clamped

        // If we hit max, allow scrolling inside
        textView.isScrollEnabled = measured > maxTextViewHeight
    }
}

extension CommentTextField: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        updateSendState()
        updateTextViewHeight()
        layoutIfNeeded()
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        // optional: highlight border on focus
        // containerView.layer.borderColor = UIColor.systemBlue.cgColor
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        // optional: restore border
        // containerView.layer.borderColor = UIColor.gray.withAlphaComponent(0.2).cgColor
    }
}
