//
//  MoreActionCell.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 1/2/26.
//
import UIKit

final class MoreActionCell: UITableViewCell {
    static let reuseID = "MoreActionCell"

    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let vStack = UIStackView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .default
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.contentMode = .scaleAspectFit

        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.numberOfLines = 1

        subtitleLabel.font = .systemFont(ofSize: 12, weight: .regular)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 2

        vStack.axis = .vertical
        vStack.alignment = .leading
        vStack.spacing = 2
        vStack.translatesAutoresizingMaskIntoConstraints = false
        vStack.addArrangedSubview(titleLabel)
        vStack.addArrangedSubview(subtitleLabel)

        contentView.addSubview(iconView)
        contentView.addSubview(vStack)

        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            iconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 22),
            iconView.heightAnchor.constraint(equalToConstant: 22),

            vStack.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            vStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            vStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            vStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(with action: MoreSheetConfig.Action) {
        titleLabel.text = action.title
        subtitleLabel.text = action.subtitle
        subtitleLabel.isHidden = (action.subtitle == nil)

        iconView.image = action.icon
        iconView.isHidden = (action.icon == nil)

        // Style colors
        let color: UIColor
        switch action.style {
        case .normal: color = .label
        case .primary: color = .systemBlue
        case .destructive: color = .systemRed
        }

        titleLabel.textColor = action.isEnabled ? color : .tertiaryLabel
        iconView.tintColor = action.isEnabled ? color : .tertiaryLabel

        isUserInteractionEnabled = action.isEnabled
        contentView.alpha = action.isEnabled ? 1.0 : 0.55
        backgroundColor = .gray.withAlphaComponent(0.15)
    }
}
