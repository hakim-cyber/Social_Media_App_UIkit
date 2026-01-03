//
//  BufferedPostsBanner.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 11/21/25.
//

import UIKit
final class BufferedPostsBanner: UIView {
    var onTap: (() -> Void)?

    private let backgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .electricPurple
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        return view
    }()

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 13, weight: .bold)
        imageView.image = UIImage(systemName: "arrow.up", withConfiguration: config)
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let textLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = .systemFont(ofSize: 15, weight: .semibold)
        
       
        l.numberOfLines = 1
        l.textColor = .white
        l.text = "New posts"
        
       
           l.adjustsFontSizeToFitWidth = true
           l.minimumScaleFactor = 0.5  // or 0.5 for more shrink
           l.lineBreakMode = .byClipping // a
        return l
    }()

    private let stackView: UIStackView = {
        let s = UIStackView()
        s.translatesAutoresizingMaskIntoConstraints = false
        s.axis = .horizontal
        s.alignment = .center
        s.spacing = 6
        s.distribution = .equalCentering
        return s
    }()

    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        translatesAutoresizingMaskIntoConstraints = false
        isUserInteractionEnabled = true

        addSubview(backgroundView)
        addSubview(stackView)

        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(textLabel)

        NSLayoutConstraint.activate([
            // Background fills entire pill
            backgroundView.topAnchor.constraint(equalTo: topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),

            // Center stack exactly in the middle of banner
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),

            // Padding ensures responsive width
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 12),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -12),
            stackView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: 6),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -6),

            // Icon size
            imageView.widthAnchor.constraint(equalToConstant: 14),
            imageView.heightAnchor.constraint(equalToConstant: 14)
        ])

        // Tap
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)
    }

    @objc private func handleTap() {
        onTap?()
    }

    func configure(count: Int) {
        textLabel.text = count == 1 ? "1 new post" : "\(count) new posts"
    }
}
