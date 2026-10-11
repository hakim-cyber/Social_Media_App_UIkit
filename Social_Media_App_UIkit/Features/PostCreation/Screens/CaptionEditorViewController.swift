//
//  CaptionEditorViewController.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 10/7/25.
//


import UIKit

final class CaptionEditorViewController: UIViewController, UITextViewDelegate {

    // MARK: Config
    private let initialText: String
    private let maxCharacters: Int
    var onUse: ((String) -> Void)?

    // MARK: UI
    private let textView = UITextView()
    private let counterLabel = UILabel()
    private let placeholderLabel = UILabel()

    init(initialText: String, maxCharacters: Int) {
        self.initialText = initialText
        self.maxCharacters = maxCharacters
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .popover
        if let sheet = sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
            sheet.largestUndimmedDetentIdentifier = .large
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupNavBar()
        setupTextView()
        setupCounter()
        applyInitial()
    }

    private func setupNavBar() {
        title = "Edit Caption"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Cancel", style: .plain, target: self, action: #selector(cancelTapped)
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Use", style: .done, target: self, action: #selector(useTapped)
        )
    }

    private func setupTextView() {
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = .preferredFont(forTextStyle: .body)
        textView.adjustsFontForContentSizeCategory = true
        textView.delegate = self
        textView.backgroundColor = .secondarySystemBackground
        textView.layer.cornerRadius = 12
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 10, bottom: 12, right: 10)
        view.addSubview(textView)

        // placeholder
        placeholderLabel.text = "Write a caption…"
        placeholderLabel.textColor = .secondaryLabel
        placeholderLabel.font = .preferredFont(forTextStyle: .body)
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        textView.addSubview(placeholderLabel)

        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            placeholderLabel.topAnchor.constraint(equalTo: textView.topAnchor, constant: 12),
            placeholderLabel.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: 14),
        ])
    }

    private func setupCounter() {
        counterLabel.translatesAutoresizingMaskIntoConstraints = false
        counterLabel.font = .preferredFont(forTextStyle: .footnote)
        counterLabel.textColor = .secondaryLabel
        counterLabel.textAlignment = .right
        view.addSubview(counterLabel)

        NSLayoutConstraint.activate([
            counterLabel.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 8),
            counterLabel.leadingAnchor.constraint(equalTo: textView.leadingAnchor),
            counterLabel.trailingAnchor.constraint(equalTo: textView.trailingAnchor),

            // give breathing room at bottom so sheet can scroll a bit
            counterLabel.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }

    private func applyInitial() {
        textView.text = initialText
        updateUIForTextChange()
        DispatchQueue.main.async { [weak self] in
            self?.textView.becomeFirstResponder()
        }
    }

    // MARK: Actions
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }

    @objc private func useTapped() {
        let text = textView.text ?? ""
        onUse?(text)
        dismiss(animated: true)
    }

    // MARK: UITextViewDelegate
    func textViewDidChange(_ textView: UITextView) {
        // enforce max length
        if textView.text.count > maxCharacters {
            let endIdx = textView.text.index(textView.text.startIndex, offsetBy: maxCharacters)
            textView.text = String(textView.text[..<endIdx])
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
        updateUIForTextChange()
    }

    private func updateUIForTextChange() {
        let count = textView.text.count
        counterLabel.text = "\(count)/\(maxCharacters)"
        placeholderLabel.isHidden = !textView.text.isEmpty

        // warn near limit
        if count > maxCharacters - 10 {
            counterLabel.textColor = .systemRed
        } else {
            counterLabel.textColor = .secondaryLabel
        }
    }
}

#Preview{
    CaptionEditorViewController(initialText: "", maxCharacters: 250)
}
