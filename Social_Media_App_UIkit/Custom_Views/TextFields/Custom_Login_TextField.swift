//
//  Custom_Login_TextField.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 9/23/25.
//



import UIKit

class CustomTextField: UIView {
    
    // MARK: - UI Elements
    var height = 40.0
    private var topLabel: UILabel?
    
    let textField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .none
        tf.backgroundColor = .clear
        tf.textColor = .label
        tf.font = .systemFont(ofSize: 12)
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private let eyeButton: UIButton = {
        let button = UIButton(type: .custom)
        let config = UIImage.SymbolConfiguration(scale: .default)
        button.setImage(UIImage(systemName: "eye.slash", withConfiguration: config), for: .normal)
        button.setImage(UIImage(systemName: "eye", withConfiguration: config), for: .selected)
       
        button.tintColor = .label
        button.isHidden = true
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
       
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Init
    init(placeholder: String, topLabelText: String? = nil, isSecure: Bool = false,height:CGFloat = 40.0) {
        super.init(frame: .zero)
        
        textField.placeholder = placeholder
        self.height = height
        
        if let topText = topLabelText {
            let label = UILabel()
            label.font = .systemFont(ofSize: 12, weight: .medium)
            label.textColor = .secondaryLabel
            label.text = topText
            label.translatesAutoresizingMaskIntoConstraints = false
            self.topLabel = label
        }
        
        setupUI()
        
        if isSecure {
            textField.isSecureTextEntry = true
            eyeButton.isHidden = false
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    
    }
    // MARK: - Setup
    private func setupUI() {
       
        if let topLabel {
            addSubview(topLabel)
            NSLayoutConstraint.activate([
                topLabel.topAnchor.constraint(equalTo: topAnchor),
                topLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
                topLabel.trailingAnchor.constraint(equalTo: trailingAnchor)
            ])
        }
        
        addSubview(containerView)
        
        // If we have a top label, pin container under it; else pin directly to top
        if let topLabel {
            NSLayoutConstraint.activate([
                containerView.topAnchor.constraint(equalTo: topLabel.bottomAnchor, constant: 7)
            ])
        } else {
            NSLayoutConstraint.activate([
                containerView.topAnchor.constraint(equalTo: topAnchor)
            ])
        }
        containerView.layer.cornerRadius = height / 2.2
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.heightAnchor.constraint(equalToConstant: height),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        containerView.addSubview(textField)
        containerView.addSubview(eyeButton)
        
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            textField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            textField.trailingAnchor.constraint(equalTo: eyeButton.leadingAnchor, constant: -8),
            
            eyeButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            
            eyeButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            eyeButton.widthAnchor.constraint(equalToConstant: height / 2.7),
            eyeButton.heightAnchor.constraint(equalToConstant: height / 3)
        ])
        
        eyeButton.addTarget(self, action: #selector(toggleSecure), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func toggleSecure() {
        textField.isSecureTextEntry.toggle()
        eyeButton.isSelected.toggle()
       
        // Fix cursor jump issue
        if let existingText = textField.text, textField.isSecureTextEntry {
            textField.deleteBackward()
            textField.insertText(existingText + " ")
            textField.deleteBackward()
        }
    }
}

#Preview {
    CustomTextField(placeholder: "Hello World",topLabelText: "Hello",isSecure: true)
}
