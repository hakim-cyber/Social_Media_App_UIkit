//
//  DividerWithText.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 9/23/25.
//

import UIKit

class DividerWithText: UIView {
    
    init(text: String) {
        super.init(frame: .zero)
        
        let leftLine = UIView()
        leftLine.backgroundColor = .secondaryLabel
        leftLine.layer.opacity = 0.2
        
        let rightLine = UIView()
        rightLine.backgroundColor = .secondaryLabel
        rightLine.layer.opacity = 0.2
        
        let label = UILabel()
        label.text = text
        label.textColor = .label
        label.font = .systemFont(ofSize: 14, weight: .regular)
        
        let stack = UIStackView(arrangedSubviews: [leftLine, label, rightLine])
        stack.axis = .horizontal
        stack.spacing = 20
        stack.alignment = .center
        
        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            leftLine.heightAnchor.constraint(equalToConstant: 1),
            rightLine.heightAnchor.constraint(equalToConstant: 1),
            
            // 👇 ensures text is always centered
            leftLine.widthAnchor.constraint(equalTo: rightLine.widthAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

#Preview {
    DividerWithText(text: "OR")
}
