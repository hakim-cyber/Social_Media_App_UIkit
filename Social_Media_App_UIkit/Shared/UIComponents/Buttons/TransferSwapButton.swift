import UIKit

final class TransferSwapButton: UIControl {

    var imageName: String = "arrow.left.arrow.right" {
        didSet {
            imageView.image = UIImage(systemName: imageName)
        }
    }

    override var isHighlighted: Bool {
        didSet {
            containerView.backgroundColor = isHighlighted
            ? .tertiarySystemFill
            : .systemBackground
        }
    }

    private let containerView = UIView()
    private let imageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false

        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .systemBackground
        containerView.layer.cornerRadius = 24
        containerView.layer.shadowColor = UIColor.black.withAlphaComponent(0.12).cgColor
        containerView.layer.shadowOpacity = 1
        containerView.layer.shadowRadius = 12
        containerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        addSubview(containerView)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: imageName)
        imageView.tintColor = .systemBlue
        imageView.contentMode = .scaleAspectFit
        imageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(
            pointSize: 18,
            weight: .semibold
        )
        containerView.addSubview(imageView)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 48),
            containerView.heightAnchor.constraint(equalToConstant: 48),

            imageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
    }
}
