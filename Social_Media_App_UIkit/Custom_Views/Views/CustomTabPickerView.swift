//
//  CustomTabPickerView.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 12/22/25.
//

import UIKit

final class ProfileTabPickerView: UIView {

    enum Tab: Int, CaseIterable {
        case grid, like, saved

        var icon: UIImage? {
            switch self {
            case .grid:  return UIImage(systemName: "square.grid.2x2")
            case .like: return UIImage(systemName: "heart")
            case .saved: return UIImage(systemName: "bookmark")
            }
        }
    }

    var onSelect: ((Tab) -> Void)?

    private let stack = UIStackView()
    private let indicator = UIView()
    private let separator = UIView()

    private var buttons: [UIButton] = []
    private var indicatorLeading: NSLayoutConstraint?
    private var indicatorWidth: NSLayoutConstraint?

    private(set) var selected: Tab = .grid

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        backgroundColor = .clear

        // Row
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        // Underline indicator
        indicator.backgroundColor = .label
        indicator.layer.cornerRadius = 1
        indicator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(indicator)

        // Bottom separator
        separator.backgroundColor = .separator
        separator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(separator)

        // Buttons
        Tab.allCases.forEach { tab in
            let b = makeButton(icon: tab.icon, count: 0)
            b.tag = tab.rawValue
            b.addTarget(self, action: #selector(didTap(_:)), for: .touchUpInside)
            buttons.append(b)
            stack.addArrangedSubview(b)
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

            indicator.topAnchor.constraint(equalTo: stack.bottomAnchor),
            indicator.heightAnchor.constraint(equalToConstant: 2)
        ])

        // initial indicator position
        layoutIfNeeded()
        updateSelection(to: .grid, animated: false)
    }

    private func makeButton(icon: UIImage?, count: Int) -> UIButton {
        var cfg = UIButton.Configuration.plain()
        cfg.image = icon
        cfg.imagePadding = 8
        cfg.title = "\(count)"
        cfg.baseForegroundColor = .secondaryLabel

        let b = UIButton(configuration: cfg)
        b.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        b.tintColor = .secondaryLabel
        return b
    }

    // Public API: update counts
    func setCounts(grid: Int, video: Int, reels: Int, saved: Int) {
        let counts = [grid, video, reels, saved]
        for (i, b) in buttons.enumerated() {
            var cfg = b.configuration
            cfg?.title = "\(counts[i])"
            b.configuration = cfg
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

        // update colors
        for b in buttons {
            let isSelected = b.tag == tab.rawValue
            var cfg = b.configuration
            cfg?.baseForegroundColor = isSelected ? .label : .secondaryLabel
            b.configuration = cfg
            b.tintColor = isSelected ? .label : .secondaryLabel
        }

        // underline geometry
        guard let selectedButton = buttons.first(where: { $0.tag == tab.rawValue }) else { return }
        let targetX = selectedButton.frame.minX
        let targetW = selectedButton.frame.width

        if indicatorLeading == nil {
            indicatorLeading = indicator.leadingAnchor.constraint(equalTo: leadingAnchor, constant: targetX)
            indicatorWidth   = indicator.widthAnchor.constraint(equalToConstant: targetW)
            indicatorLeading?.isActive = true
            indicatorWidth?.isActive = true
            layoutIfNeeded()
            return
        }

        indicatorLeading?.constant = targetX
        indicatorWidth?.constant = targetW

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
        // keep indicator correct after rotation / size changes
        updateSelection(to: selected, animated: false)
    }
}

#Preview(){
    ProfileTabPickerView()
}
