//
//  MoreSheetHeaderView.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 1/2/26.
//
import UIKit

final class MoreSheetHeaderView: UIView {
    let avatarView = RoundedImageView(url: nil, isCircular: true)
    private let usernameLabel = UILabel()
    private let fullNameLabel = UILabel()
    private let verifiedView = UIImageView()

    private let titleLabel = UILabel()
    private let messageLabel = UILabel()

    private let topRow = UIStackView()
    private let textStack = UIStackView()
    private let root = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear

        avatarView.translatesAutoresizingMaskIntoConstraints = false
     

        usernameLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        usernameLabel.numberOfLines = 1

        fullNameLabel.font = .systemFont(ofSize: 12, weight: .regular)
        fullNameLabel.textColor = .secondaryLabel
        fullNameLabel.numberOfLines = 1

        verifiedView.image = UIImage(systemName: "checkmark.seal.fill")
        verifiedView.tintColor = .systemBlue
        verifiedView.contentMode = .scaleAspectFit
        verifiedView.translatesAutoresizingMaskIntoConstraints = false
       
        titleLabel.font = .systemFont(ofSize: 17, weight: .bold)
        titleLabel.numberOfLines = 2

        messageLabel.font = .systemFont(ofSize: 13, weight: .regular)
        messageLabel.textColor = .secondaryLabel
        messageLabel.numberOfLines = 0

        textStack.axis = .vertical
        textStack.alignment = .center
        textStack.spacing = 2
        textStack.addArrangedSubview(usernameLabel)
        textStack.addArrangedSubview(fullNameLabel)

        topRow.axis = .vertical
        topRow.alignment = .center
        topRow.spacing = 10
        topRow.addArrangedSubview(avatarView)
        topRow.addArrangedSubview(textStack)

        root.axis = .vertical
        root.alignment = .center
        root.spacing = 10
        root.translatesAutoresizingMaskIntoConstraints = false

        addSubview(root)

        NSLayoutConstraint.activate([
            root.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            root.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            root.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            root.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),

            avatarView.widthAnchor.constraint(equalToConstant: 44),
            avatarView.heightAnchor.constraint(equalToConstant: 44),
        ])
        self.usernameLabel.addSubview(verifiedView)

        NSLayoutConstraint.activate([
            verifiedView.widthAnchor.constraint(equalToConstant: 13),
            verifiedView.heightAnchor.constraint(equalToConstant: 13),
            verifiedView.leadingAnchor.constraint(equalTo: self.usernameLabel.trailingAnchor,constant: 2),
            verifiedView.centerYAnchor.constraint(equalTo: self.usernameLabel.centerYAnchor)
        ])

    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func apply(header: MoreSheetConfig.Header?, title: String?, message: String?) {
        root.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // Header
        if let header {
            usernameLabel.text = header.username
            fullNameLabel.text = header.fullName
            fullNameLabel.isHidden = (header.fullName == nil)
            verifiedView.isHidden = !header.isVerified

            // Avatar
            switch header.avatar {
            case .image(let img):
                avatarView.image = img
            case .url(let url):
                // plug your Kingfisher or your RoundedImageView logic here:
                // avatarView.kf.setImage(with: url)
                if let url {
                    avatarView.setImage(url: url)
                }
            }

            root.addArrangedSubview(topRow)
        }

        // Title/message
        if let title, !title.isEmpty {
            titleLabel.text = title
            root.addArrangedSubview(titleLabel)
        }
        if let message, !message.isEmpty {
            messageLabel.text = message
            root.addArrangedSubview(messageLabel)
        }

        isHidden = root.arrangedSubviews.isEmpty
    }
}
