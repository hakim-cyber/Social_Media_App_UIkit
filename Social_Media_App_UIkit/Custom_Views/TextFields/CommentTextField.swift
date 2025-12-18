//
//  CommentTextField.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 12/19/25.
//

import UIKit

final class CommentTextField: UIView {

    // MARK: - Public API
    var onSend: ((String) -> Void)?

    // MARK: - UI
    private let containerView: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor.secondaryLabel.cgColor
        v.layer.cornerRadius = 20
        v.isUserInteractionEnabled = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    let textField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "What do you think?"
        tf.font = .systemFont(ofSize: 16)
        tf.backgroundColor = .clear
        tf.borderStyle = .none
        tf.returnKeyType = .send
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    let sendButton = CustomImageButton(backgroundColor: .electricPurple, systemImage:   "arrow.up",cornerRadius: 16)
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        setupUI()
        setupActions()
        setupTapToFocus()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Setup
    private func setupUI() {
        addSubview(containerView)
        containerView.addSubview(textField)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.isHidden = true
        sendButton.isUserInteractionEnabled = false
        containerView.addSubview(sendButton)

        NSLayoutConstraint.activate([
            // container inside self
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            containerView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),

            // ✅ minimum height for whole component
            heightAnchor.constraint(greaterThanOrEqualToConstant: 46),

            // send button (fixed tap size)
            sendButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 56),
            sendButton.heightAnchor.constraint(equalToConstant: 36),

            // textfield
            textField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 14),
            textField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -10),
            textField.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            textField.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10)
        ])
    }

    private func setupActions() {
        textField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        textField.addTarget(self, action: #selector(returnPressed), for: .editingDidEndOnExit)
        sendButton.tapAction = { [weak self] in
            self?.sendTapped()
        }
    }

    private func setupTapToFocus() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(containerTapped))
        containerView.addGestureRecognizer(tap)
    }

    // MARK: - Actions
    @objc private func containerTapped() {
        textField.becomeFirstResponder() // ✅ makes it tappable even if user taps border area
    }

    @objc private func textDidChange() {
        let hasText = !(textField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
      
        sendButton.isHidden = !hasText
        sendButton.isUserInteractionEnabled = hasText
    }

    @objc private func returnPressed() {
        sendTapped()
    }

    @objc private func sendTapped() {
        guard let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !text.isEmpty else { return }

        onSend?(text)

        
//        
//
//        textField.text = ""
//      
//        sendButton.isHidden = true
//        sendButton.isUserInteractionEnabled = false
        
        // make these after already sent the text
        
        
        
    }
    
    // make these after already sent the text
    func emptyText() {
        textField.text = ""
        sendButton.isHidden = true
        sendButton.isUserInteractionEnabled = false
    }
}
