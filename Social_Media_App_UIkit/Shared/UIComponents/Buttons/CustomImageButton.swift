import UIKit

final class CustomImageButton: UIView {

    private let imageView = UIImageView()
    var tapAction: (() -> Void)?

    init(backgroundColor: UIColor, systemImage: String, cornerRadius: CGFloat = 10) {
        super.init(frame: .zero)

        self.backgroundColor = backgroundColor
        self.layer.cornerRadius = cornerRadius
        self.clipsToBounds = true
        self.translatesAutoresizingMaskIntoConstraints = false

        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)
        let image = UIImage(systemName: systemImage, withConfiguration: config)

        setupImageView(image: image)
        setupLayout()
        setupGesture()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupImageView(image: UIImage?) {
        // ✅ If image is nil, you know the symbol name is invalid
        if image == nil {
            print("❌ SF Symbol not found:", image as Any)
        }

        imageView.image = image?.withRenderingMode(.alwaysTemplate) // ✅ IMPORTANT
        imageView.tintColor = .white                                 // ✅ IMPORTANT
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 18),
            imageView.heightAnchor.constraint(equalToConstant: 18),
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
