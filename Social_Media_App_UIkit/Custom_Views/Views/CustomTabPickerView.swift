import UIKit

final class ProfileTabPickerView: UIView {

    enum Tab: Int, CaseIterable {
        case grid, like, saved

        func icon(selected: Bool) -> UIImage? {
            switch self {
            case .grid:  return UIImage(systemName: selected ? "square.grid.2x2.fill" : "square.grid.2x2")
            case .like:  return UIImage(systemName: selected ? "heart.fill" : "heart")
            case .saved: return UIImage(systemName: selected ? "bookmark.fill" : "bookmark")
            }
        }
    }

    var onSelect: ((Tab) -> Void)?

    private let stack = UIStackView()
    private let indicator = UIView()
    private let separator = UIView()

    private var buttons: [UIButton] = []
    private var indicatorLeading: NSLayoutConstraint!
    private var indicatorWidth: NSLayoutConstraint!

    private(set) var selected: Tab = .grid
    private var isCurrentUser: Bool = false 
    init(frame: CGRect = .zero,isCurrentUser: Bool ) {
        self.isCurrentUser = isCurrentUser
        super.init(frame: frame)
        setup()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private var isSavedDisabled: Bool {
        return !isCurrentUser
    }
    private func setup() {
        backgroundColor = .clear

        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        separator.backgroundColor = .separator
        separator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(separator)

        indicator.backgroundColor = .label
        indicator.layer.cornerRadius = 1
        indicator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(indicator)

        Tab.allCases.forEach { tab in
            if tab == .saved, isSavedDisabled {
                let b = makeButton(tab: tab)
                b.tag = tab.rawValue
                b.isUserInteractionEnabled = false
                buttons.append(b)
                stack.addArrangedSubview(b)
               
            }else{
                let b = makeButton(tab: tab)
                b.tag = tab.rawValue
                b.addTarget(self, action: #selector(didTap(_:)), for: .touchUpInside)
                buttons.append(b)
                stack.addArrangedSubview(b)
            }
        }

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.heightAnchor.constraint(equalToConstant: 44),

            separator.topAnchor.constraint(equalTo: stack.bottomAnchor),
            separator.leadingAnchor.constraint(equalTo: leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: trailingAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1),

            indicator.bottomAnchor.constraint(equalTo: separator.bottomAnchor),
            indicator.heightAnchor.constraint(equalToConstant: 2),
        ])

        indicatorLeading = indicator.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0)
        indicatorWidth   = indicator.widthAnchor.constraint(equalToConstant: 0)
        indicatorLeading.isActive = true
        indicatorWidth.isActive = true

        // initial visuals
        applySelectionVisuals(selected)

        // initial underline after we have frames
        DispatchQueue.main.async { [weak self] in
            self?.updateIndicator(animated: false)
        }
    }

    private func makeButton(tab: Tab) -> UIButton {
        var cfg = UIButton.Configuration.plain()
        if tab == .saved, isSavedDisabled {
            cfg.image =  UIImage(systemName:"bookmark.slash")
        }else{
            cfg.image = tab.icon(selected: tab == selected)
        }
        cfg.imagePadding = 8
        cfg.title = "0"
        cfg.baseForegroundColor = (tab == selected) ? .label : .secondaryLabel

        let b = UIButton(configuration: cfg)
        b.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        b.tintColor = (tab == selected) ? .label : .secondaryLabel
        return b
    }

    func setCounts(grid: Int? = nil, like: Int? = nil, saved: Int? = nil) {
        let counts = [grid, like, saved]
        for (i, b) in buttons.enumerated() {
           
            if let count = counts[i]{
                var cfg = b.configuration
                cfg?.title = count.shortFormatted
                b.configuration = cfg
            }
        }
    }

    func setSelected(_ tab: Tab, animated: Bool = true) {
        updateSelection(to: tab, animated: animated)
    }

    @objc private func didTap(_ sender: UIButton) {
        guard let tab = Tab(rawValue: sender.tag) else { return }
        updateSelection(to: tab, animated: true)
        onSelect?(tab)
    }

    private func updateSelection(to tab: Tab, animated: Bool) {
        selected = tab
        applySelectionVisuals(tab)
        updateIndicator(animated: animated)   // ✅ move underline NOW
    }

    private func applySelectionVisuals(_ tab: Tab) {
        for b in buttons {
            guard let t = Tab(rawValue: b.tag) else { continue }
            let isSelected = (t == tab)

            var cfg = b.configuration
            if t == .saved, isSavedDisabled {
                        cfg?.image = UIImage(systemName: "bookmark.slash")
                        // optionally dim it
                        cfg?.baseForegroundColor = .tertiaryLabel
                        b.isUserInteractionEnabled = false
                        b.tintColor = .tertiaryLabel
                    } else {
                        cfg?.baseForegroundColor = isSelected ? .label : .secondaryLabel
                        cfg?.image = t.icon(selected: isSelected)
                        b.configuration = cfg
                        b.tintColor = isSelected ? .label : .secondaryLabel
                    }
        }
    }

    private func updateIndicator(animated: Bool) {
        // ensure frames are correct
        stack.layoutIfNeeded()

        guard let selectedButton = buttons.first(where: { $0.tag == selected.rawValue }) else { return }

        let x = selectedButton.frame.minX
        let w = selectedButton.frame.width

        indicatorLeading.constant = x
        indicatorWidth.constant = w
        indicator.isHidden = (w <= 0.5)

        if animated {
            UIView.animate(withDuration: 0.22, delay: 0, options: [.curveEaseInOut]) {
                self.layoutIfNeeded()
            }
        } else {
            layoutIfNeeded()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // keep underline correct after rotation / size changes
        updateIndicator(animated: false)
    }
}
#Preview(){
    ProfileTabPickerView(frame: .zero, isCurrentUser: true)
}
