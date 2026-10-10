import UIKit

final class AccountSelectionButton: UIControl {

    enum LeadingContent {
        case systemImage(String)
        case text(String)
    }

    struct Content {
        let title: String
        let valueText: String?
        let placeholderText: String
        let leadingContent: LeadingContent
        let accentColor: UIColor

        init(
            title: String,
            valueText: String? = nil,
            placeholderText: String = "Kart/Hesab",
            leadingContent: LeadingContent = .systemImage("plus"),
            accentColor: UIColor = .systemBlue
        ) {
            self.title = title
            self.valueText = valueText
            self.placeholderText = placeholderText
            self.leadingContent = leadingContent
            self.accentColor = accentColor
        }
    }

    var content: Content {
        didSet {
            applyContent()
        }
    }

    var errorText: String? {
        didSet {
            errorLabel.setErrorText(errorText)
            updateAppearance()
        }
    }

    override var isHighlighted: Bool {
        didSet {
            containerView.backgroundColor = isHighlighted
            ? UIColor.systemGray6
            : .systemBackground
        }
    }

    private let stackView = UIStackView()
    private let containerView = UIView()
    private let leadingBackgroundView = UIView()
    private let iconImageView = UIImageView()
    private let iconTextLabel = UILabel()
    private let labelsStackView = UIStackView()
    private let titleLabel = UILabel()
    private let detailLabel = UILabel()
    private let errorLabel = InlineErrorLabel()

    init(content: Content = Content(title: "")) {
        self.content = content
        super.init(frame: .zero)
        configure()
        applyContent()
    }

    required init?(coder: NSCoder) {
        self.content = Content(title: "")
        super.init(coder: coder)
        configure()
        applyContent()
    }

    func setErrorText(_ text: String?) {
        errorText = text
    }

    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        accessibilityTraits = [.button]

        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 8
        addSubview(stackView)

        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .systemBackground
        containerView.layer.cornerRadius = 16
        containerView.layer.masksToBounds = true

        leadingBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        leadingBackgroundView.backgroundColor = .tertiarySystemFill
        leadingBackgroundView.layer.cornerRadius = 14

        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(
            pointSize: 22,
            weight: .regular
        )

        iconTextLabel.translatesAutoresizingMaskIntoConstraints = false
        iconTextLabel.font = .systemFont(ofSize: 28, weight: .regular)
        iconTextLabel.textAlignment = .center
        iconTextLabel.isHidden = true

        titleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = .label

        detailLabel.font = .systemFont(ofSize: 14, weight: .regular)
        detailLabel.textColor = .secondaryLabel
        detailLabel.lineBreakMode = .byTruncatingMiddle

        labelsStackView.translatesAutoresizingMaskIntoConstraints = false
        labelsStackView.axis = .vertical
        labelsStackView.spacing = 4
        labelsStackView.alignment = .leading
        labelsStackView.addArrangedSubview(titleLabel)
        labelsStackView.addArrangedSubview(detailLabel)

        [leadingBackgroundView, labelsStackView].forEach { containerView.addSubview($0) }
        [iconImageView, iconTextLabel].forEach { leadingBackgroundView.addSubview($0) }

        stackView.addArrangedSubview(containerView)
        stackView.addArrangedSubview(errorLabel)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),

            containerView.heightAnchor.constraint(equalToConstant: 78),

            leadingBackgroundView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            leadingBackgroundView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            leadingBackgroundView.widthAnchor.constraint(equalToConstant: 52),
            leadingBackgroundView.heightAnchor.constraint(equalToConstant: 52),

            labelsStackView.leadingAnchor.constraint(equalTo: leadingBackgroundView.trailingAnchor, constant: 12),
            labelsStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -14),
            labelsStackView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),

            iconImageView.centerXAnchor.constraint(equalTo: leadingBackgroundView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: leadingBackgroundView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),

            iconTextLabel.centerXAnchor.constraint(equalTo: leadingBackgroundView.centerXAnchor),
            iconTextLabel.centerYAnchor.constraint(equalTo: leadingBackgroundView.centerYAnchor),

            errorLabel.leadingAnchor.constraint(equalTo: stackView.leadingAnchor)
        ])
    }

    private func applyContent() {
        titleLabel.text = content.title
        updateDetailText()
        applyLeadingContent()
        updateAppearance()
    }

    private func updateDetailText() {
        let hasValue = !(content.valueText?.isEmpty ?? true)
        detailLabel.text = hasValue ? content.valueText : content.placeholderText
        detailLabel.textColor = hasValue ? .secondaryLabel : .secondaryLabel
    }

    private func applyLeadingContent() {
        let tintColor = content.accentColor
        iconImageView.tintColor = tintColor
        iconTextLabel.textColor = tintColor

        switch content.leadingContent {
        case .systemImage(let imageName):
            iconImageView.isHidden = false
            iconTextLabel.isHidden = true
            iconImageView.image = UIImage(systemName: imageName)
        case .text(let value):
            iconImageView.isHidden = true
            iconTextLabel.isHidden = false
            iconTextLabel.text = value
        }
    }

    private func updateAppearance() {
        let hasError = !(errorText?.isEmpty ?? true)
        containerView.layer.borderWidth = hasError ? 1 : 0
        containerView.layer.borderColor = hasError ? UIColor.systemRed.cgColor : UIColor.clear.cgColor
    }
}
