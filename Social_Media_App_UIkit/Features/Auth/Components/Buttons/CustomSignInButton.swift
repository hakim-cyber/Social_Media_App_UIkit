//
//  CustomSignIn_Button.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 9/23/25.
//
import UIKit
class CustomSignInButton: UIView {
    
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
     var tapAction: (() -> Void)?
    
    init(backgroundColor: UIColor, title: String, image: UIImage?, cornerRadius: CGFloat = 10) {
        super.init(frame: .zero)
        self.backgroundColor = backgroundColor
        self.layer.cornerRadius = cornerRadius
      
        
        setupImageView(image: image)
        setupTitleLabel(title: title)
        setupLayout()
        setupGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupImageView(image: UIImage?) {
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
    }
    
    private func setupTitleLabel(title: String) {
        titleLabel.text = title
        titleLabel.textColor = .label
        titleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
           
            imageView.trailingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: -12),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 20),
            imageView.heightAnchor.constraint(equalToConstant: 20),
        
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor,constant: 10)
        ])
    }
    
    private func setupGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)
        isUserInteractionEnabled = true
    }
    
    @objc private func handleTap() {
        tapAction?()
    }
}

#Preview {
    CustomSignInButton(backgroundColor: .secondarySystemBackground, title: "Sigb ubn with apple", image: .appleLogo)
}
