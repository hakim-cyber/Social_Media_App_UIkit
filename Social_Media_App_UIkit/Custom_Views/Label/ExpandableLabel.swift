import UIKit

public final class ExpandableLabel: UILabel {

    // MARK: Public API
    public var collapsedNumberOfLines: Int = 2 {
        didSet {
            if !isExpanded {
                numberOfLines = collapsedNumberOfLines
                tc.maximumNumberOfLines = collapsedNumberOfLines
                rebuild()
            }
        }
    }
    public var moreText: String = " ...more"
    public var lessText: String = " ...less"
    public var tokenColor: UIColor = .label
    public var onToggle: ((Bool) -> Void)?   // isExpanded

    public override var text: String? {
        didSet {
            if let t = text {
                let attrs: [NSAttributedString.Key: Any] = [
                    .font: font as Any,
                    .foregroundColor: textColor as Any
                ]
                original = NSAttributedString(string: t, attributes: attrs)
            } else {
                original = nil
            }
            rebuild()
        }
    }

    public override var attributedText: NSAttributedString? {
        didSet {
            original = attributedText
            rebuild()
        }
    }

    // MARK: Internals
    private var isExpanded = false
    private var isExpandable = false   // NEW: text actually overflows?
    private var original: NSAttributedString?

    // TextKit (only for measuring/truncation)
    private let lm = NSLayoutManager()
    private let tc = NSTextContainer(size: .zero)
    private let ts = NSTextStorage()

    // MARK: Init
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        numberOfLines = collapsedNumberOfLines
        lineBreakMode = .byWordWrapping
        isUserInteractionEnabled = true

        let tap = UITapGestureRecognizer(target: self, action: #selector(toggleTap))
        tap.cancelsTouchesInView = false
        addGestureRecognizer(tap)

        tc.lineFragmentPadding = 0
        tc.maximumNumberOfLines = collapsedNumberOfLines
        tc.lineBreakMode = lineBreakMode
        lm.usesFontLeading = true
        lm.addTextContainer(tc)
        ts.addLayoutManager(lm)
    }

    // MARK: Layout
    public override func layoutSubviews() {
        super.layoutSubviews()
        let textRect = self.textRect(forBounds: bounds, limitedToNumberOfLines: numberOfLines)
        tc.size = CGSize(width: max(0, textRect.width), height: .greatestFiniteMagnitude)
        rebuild() // ensures token appears/disappears after width changes
    }

    // MARK: Toggle
    @objc private func toggleTap() {
        guard isExpandable else { return }      // NEW: əgər mətni expand eləmək lazım deyil, tap heç nə etmir
        setExpanded(!isExpanded, animated: true)
    }

    public func setExpanded(_ expanded: Bool, animated: Bool = true) {
        guard isExpandable else { return }      // NEW: proqramdan da çağırsan, expand olmasın
        guard isExpanded != expanded else { return }

        isExpanded = expanded
        numberOfLines = expanded ? 0 : collapsedNumberOfLines
        tc.maximumNumberOfLines = expanded ? 0 : collapsedNumberOfLines

        rebuild()
        onToggle?(isExpanded)
    }

    // MARK: Build
    private func rebuild() {
        guard let source = original, bounds.width > 0 else { return }

        let f = font ?? .systemFont(ofSize: 15)

        // Əvvəlcə: bu mətn ümumiyyətlə collapsedNumberOfLines-a sığır, yoxsa yox?
        wire(source)
        tc.maximumNumberOfLines = collapsedNumberOfLines
        let visibleRange = lm.glyphRange(for: tc)
        let allFit = NSMaxRange(visibleRange) >= lm.numberOfGlyphs

        // Əgər hamısı sığırsa → expand edilməməlidir
        if allFit || moreText.isEmpty {
            isExpandable = false
            isExpanded = false
            numberOfLines = collapsedNumberOfLines
            tc.maximumNumberOfLines = collapsedNumberOfLines
            super.attributedText = source
            wire(source)
            invalidateIntrinsicContentSize()
            return
        }

        // Burdan aşağı deməkdir ki, mətn truncation tələb edir → expand oluna bilər
        isExpandable = true

        if isExpanded {
            // full text + optional " ...less"
            if lessText.isEmpty {
                super.attributedText = source
            } else {
                let m = NSMutableAttributedString(attributedString: source)
                m.append(NSAttributedString(
                    string: lessText,
                    attributes: [.font: f, .foregroundColor: tokenColor]
                ))
                super.attributedText = m
            }
            wire(super.attributedText!)
            invalidateIntrinsicContentSize()
            return
        }

        // Collapsed: lazım olan qədər kəs + " ...more"
        let token = NSAttributedString(
            string: moreText,
            attributes: [.font: f, .foregroundColor: tokenColor]
        )

        var lo = 0, hi = source.length, best = 0
        while lo <= hi {
            let mid = (lo + hi) / 2
            let candidate = NSMutableAttributedString(
                attributedString: source.attributedSubstring(
                    from: NSRange(location: 0, length: max(0, mid))
                )
            )
            candidate.append(token)
            wire(candidate)
            tc.maximumNumberOfLines = collapsedNumberOfLines
            let fits = NSMaxRange(lm.glyphRange(for: tc)) >= lm.numberOfGlyphs
            if fits {
                best = mid
                lo = mid + 1
            } else {
                hi = mid - 1
            }
        }

        let final = NSMutableAttributedString(
            attributedString: source.attributedSubstring(
                from: NSRange(location: 0, length: max(0, best))
            )
        )
        final.append(token)
        super.attributedText = final
        wire(final)
        invalidateIntrinsicContentSize()
    }

    private func wire(_ attr: NSAttributedString) {
        ts.setAttributedString(attr)
        tc.lineBreakMode = lineBreakMode
    }
}
