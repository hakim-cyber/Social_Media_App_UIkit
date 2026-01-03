//
//  UnderlinedButton.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 9/29/25.
//
import UIKit

class UnderlinedButton: UIButton {
    
    // MARK: - Properties
    var underline: Bool = false {
        didSet { updateTitle() }
    }
    
    var underlineColor: UIColor? = nil {
        didSet { updateTitle() }
    }
    
    var customFont: UIFont? = nil {
        didSet { updateTitle() }
    }
    
    var textColor: UIColor = .systemBlue {
        didSet { updateTitle() }
    }
    
    // MARK: - Custom Initializer
    init(title: String,
         underline: Bool = false,
         underlineColor: UIColor? = nil,
         textColor: UIColor = .systemBlue,
         font: UIFont? = nil,
         buttonType: UIButton.ButtonType = .system) {
        
       
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.underline = underline
        self.underlineColor = underlineColor
        self.textColor = textColor
        self.customFont = font
        self.setTitle(title, for: .normal)
        updateTitle()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - Override setTitle
    override func setTitle(_ title: String?, for state: UIControl.State) {
        super.setTitle(title, for: state)
        updateTitle()
    }
    
    // MARK: - Update Attributed Title
    private func updateTitle() {
        guard let titleText = title(for: .normal) else { return }
        
        var attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: textColor,
            .font: customFont ?? titleLabel?.font ?? UIFont.systemFont(ofSize: 17)
        ]
        
        if underline {
            attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
            if let underlineColor = underlineColor {
                attributes[.underlineColor] = underlineColor
            }
        }
        
        let attributedString = NSAttributedString(string: titleText, attributes: attributes)
        setAttributedTitle(attributedString, for: .normal)
    }
}

/* Usage
 let button = UnderlinedButton(
     title: "Tap Me",
     underline: true,
     underlineColor: .red,
     textColor: .black,
     font: UIFont.boldSystemFont(ofSize: 18)
 )
 */
