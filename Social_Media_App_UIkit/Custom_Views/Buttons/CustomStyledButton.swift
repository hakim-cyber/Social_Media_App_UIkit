//
//  CustomStyledButton.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 12/21/25.
//

import UIKit
import UIKit

final class CustomStyledButton: UIButton {

    // MARK: - Style model
    struct Style {
        let backgroundColor: UIColor
        let titleColor: UIColor
        let cornerRadius: CGFloat
        let borderWidth: CGFloat
        let borderColor: UIColor

        static let primary = Style(
            backgroundColor: .electricPurple,
            titleColor: .white,
            cornerRadius: 20,
            borderWidth: 0,
            borderColor: .clear
        )

        static let secondary = Style(
            backgroundColor: .clear,
            titleColor: UIColor.label,
            cornerRadius: 20,
            borderWidth: 1,
            borderColor: UIColor.gray.withAlphaComponent(0.4)
        )
    }

    // MARK: - Private
    private var currentStyle: Style?

    // MARK: - Init
    init(frame: CGRect = .zero,style: Style,text:String) {
        self.currentStyle = style
        super.init(frame: frame)
        self.setTitle(text)
        self.applyStyle(style: style)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
     
    }


    // MARK: - Public API
    func applyStyle(style: Style) {
        currentStyle = style

        backgroundColor = style.backgroundColor
        setTitleColor(style.titleColor, for: .normal)
        self.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)

        layer.cornerRadius = style.cornerRadius
        layer.borderWidth = style.borderWidth
        layer.borderColor = style.borderColor.cgColor
        
       
    }

    func setTitle(_ title: String) {
        setTitle(title, for: .normal)
    }

    // MARK: - States
    override var isHighlighted: Bool {
        didSet {
            guard let style = currentStyle else { return }
            if style.backgroundColor == .clear{
                backgroundColor = isHighlighted
                ? UIColor.systemGray.withAlphaComponent(0.05)
                : UIColor.clear
            }else{
                backgroundColor = isHighlighted
                ? style.backgroundColor.withAlphaComponent(0.9)
                : style.backgroundColor
            }
        }
    }

    override var isEnabled: Bool {
        didSet {
            alpha = isEnabled ? 1.0 : 0.9
        }
    }
}
