import UIKit

final class InlineErrorLabel: UILabel {

    var textInsets = UIEdgeInsets.zero {
        didSet {
            invalidateIntrinsicContentSize()
            setNeedsDisplay()
        }
    }

    override var text: String? {
        didSet {
            isHidden = (text?.isEmpty ?? true)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    func setErrorText(_ text: String?) {
        self.text = text
    }

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textInsets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(
            width: size.width + textInsets.left + textInsets.right,
            height: size.height + textInsets.top + textInsets.bottom
        )
    }

    private func configure() {
        font = .systemFont(ofSize: 12, weight: .medium)
        textColor = .systemRed
        numberOfLines = 0
        textAlignment = .left
        translatesAutoresizingMaskIntoConstraints = false
        isHidden = true
    }
}
