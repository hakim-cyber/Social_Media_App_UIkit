//
//  UnderlinedTextField.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 9/30/25.
//


import UIKit
import UIKit

class UnderlinedTextFieldView: UIView {
    
    var paddingBetween:CGFloat = 4.0
    var underlineHeight:CGFloat = 1.0
    var titleColor:UIColor = .label
    var textColor:UIColor = .label
    var underlineColor = UIColor.systemGray3
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Username"
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let textField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .none
        tf.font = .systemFont(ofSize: 16)
        
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private let underline: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray3
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    func changeUnderlineColor(color:UIColor){
        self.underlineColor = color
        self.underline.backgroundColor = color
    }
    private func setupView() {
        titleLabel.textColor = titleColor
        underline.backgroundColor = underlineColor
        textField.textColor = textColor
        addSubview(titleLabel)
        addSubview(textField)
        addSubview(underline)
        
        NSLayoutConstraint.activate([
            // Title at top leading
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            
            // TextField below title
            textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: paddingBetween),
            textField.leadingAnchor.constraint(equalTo: leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            // Underline
            underline.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: paddingBetween),
            underline.leadingAnchor.constraint(equalTo: leadingAnchor),
            underline.trailingAnchor.constraint(equalTo: trailingAnchor),
            underline.heightAnchor.constraint(equalToConstant: underlineHeight),
            
            underline.bottomAnchor.constraint(equalTo: bottomAnchor) // container height
        ])
    }
}
