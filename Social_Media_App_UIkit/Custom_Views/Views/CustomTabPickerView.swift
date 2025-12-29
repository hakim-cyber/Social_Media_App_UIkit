import UIKit

// MARK: - Reusable Tab Picker

final class TabPickerView<ID: Hashable>: UIView {

    // MARK: Model
    struct Item: Hashable {
        let id: ID

        var selectedIcon: UIImage?
        var unselectedIcon: UIImage?

        /// Optional: use for counts (e.g. "12") or label
        var title: String?

        var isEnabled: Bool = true
        var disabledIcon: UIImage? = nil

        public init(
            id: ID,
            selectedIcon: UIImage?,
            unselectedIcon: UIImage?,
            title: String? = nil,
            isEnabled: Bool = true,
            disabledIcon: UIImage? = nil
        ) {
            self.id = id
            self.selectedIcon = selectedIcon
            self.unselectedIcon = unselectedIcon
            self.title = title
            self.isEnabled = isEnabled
            self.disabledIcon = disabledIcon
        }
    }

    // MARK: Public API
    var onSelect: ((ID) -> Void)?

    private(set) var selectedID: ID

    // Styling (simple defaults; tweak if you want)
    var selectedColor: UIColor = .label
    var unselectedColor: UIColor = .secondaryLabel
    var disabledColor: UIColor = .tertiaryLabel
    var indicatorColor: UIColor = .label
    var separatorColor: UIColor = .separator
    var height: CGFloat = 44
    var indicatorHeight: CGFloat = 2
    var font: UIFont = .systemFont(ofSize: 16, weight: .medium)

    // MARK: Internals
    private let stack = UIStackView()
    private let indicator = UIView()
    private let separator = UIView()

    private var buttons: [UIButton] = []
    private var items: [Item] = []

    private var indicatorLeading: NSLayoutConstraint!
    private var indicatorWidth: NSLayoutConstraint!

    // MARK: Init
    init(items: [Item], selectedID: ID) {
        self.selectedID = selectedID
        self.items = items
        super.init(frame: .zero)
        setup()
        applyItems(items, animated: false)
        setSelected(selectedID, animated: false)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Public updates
    func applyItems(_ newItems: [Item], animated: Bool = false) {
        items = newItems
        rebuildButtons()
        applySelectionVisuals()
        updateIndicator(animated: animated)
    }

    func setSelected(_ id: ID, animated: Bool = true) {
        selectedID = id
        applySelectionVisuals()
        updateIndicator(animated: animated)
    }

    /// Generic title update (use it for counts)
    func setTitle(_ title: String?, for id: ID) {
        guard let idx = items.firstIndex(where: { $0.id == id }) else { return }
        items[idx].title = title
        // update only that button
        guard idx < buttons.count else { return }
        applyConfig(to: buttons[idx], item: items[idx], isSelected: items[idx].id == selectedID)
    }

    // MARK: Setup
    private func setup() {
        backgroundColor = .clear

        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        separator.backgroundColor = separatorColor
        separator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(separator)

        indicator.backgroundColor = indicatorColor
        indicator.layer.cornerRadius = 1
        indicator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(indicator)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.heightAnchor.constraint(equalToConstant: height),

            separator.topAnchor.constraint(equalTo: stack.bottomAnchor),
            separator.leadingAnchor.constraint(equalTo: leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: trailingAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1),

            indicator.bottomAnchor.constraint(equalTo: separator.bottomAnchor),
            indicator.heightAnchor.constraint(equalToConstant: indicatorHeight),
        ])

        indicatorLeading = indicator.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0)
        indicatorWidth   = indicator.widthAnchor.constraint(equalToConstant: 0)
        indicatorLeading.isActive = true
        indicatorWidth.isActive = true

        rebuildButtons()

        // initial underline after layout
        DispatchQueue.main.async { [weak self] in
            self?.updateIndicator(animated: false)
        }
    }

    private func rebuildButtons() {
        // clear
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        buttons.removeAll()

        for (index, item) in items.enumerated() {
            let b = UIButton(type: .system)
            b.tag = index
            b.titleLabel?.font = font

            if item.isEnabled {
                b.addTarget(self, action: #selector(didTap(_:)), for: .touchUpInside)
            } else {
                b.isUserInteractionEnabled = false
            }

            buttons.append(b)
            stack.addArrangedSubview(b)

            // configure initial
            applyConfig(to: b, item: item, isSelected: item.id == selectedID)
        }
    }

    @objc private func didTap(_ sender: UIButton) {
        let idx = sender.tag
        guard idx >= 0, idx < items.count else { return }

        let item = items[idx]
        guard item.isEnabled else { return }

        setSelected(item.id, animated: true)
        onSelect?(item.id)
    }

    private func applySelectionVisuals() {
        for (i, b) in buttons.enumerated() {
            guard i < items.count else { continue }
            let item = items[i]
            let isSelected = (item.id == selectedID)
            applyConfig(to: b, item: item, isSelected: isSelected)
        }
    }

    private func applyConfig(to button: UIButton, item: Item, isSelected: Bool) {
        var cfg = UIButton.Configuration.plain()
        cfg.imagePadding = 8
        cfg.title = item.title

        if !item.isEnabled {
            cfg.image = item.disabledIcon ?? item.unselectedIcon
            cfg.baseForegroundColor = disabledColor
            button.tintColor = disabledColor
        } else {
            cfg.image = isSelected ? item.selectedIcon : item.unselectedIcon
            cfg.baseForegroundColor = isSelected ? selectedColor : unselectedColor
            button.tintColor = isSelected ? selectedColor : unselectedColor
        }

        button.configuration = cfg
    }

    private func updateIndicator(animated: Bool) {
        stack.layoutIfNeeded()

        guard let idx = items.firstIndex(where: { $0.id == selectedID }),
              idx < buttons.count else { return }

        let selectedButton = buttons[idx]
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
        updateIndicator(animated: false)
    }
}
