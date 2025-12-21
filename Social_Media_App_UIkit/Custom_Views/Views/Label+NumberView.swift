//
//  Label+NumberView.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 12/21/25.
//

import Foundation
import UIKit

class LabelNumberView: UIView {
    
    var number:Int
    var text:String
   
    var textLabel:UILabel = UILabel()
    var numberLabel:UILabel = UILabel()
    init(text: String,number:Int) {
        self.text = text
        self.number = number
        super.init(frame: .zero)
        self.textLabel.text = text
        self.numberLabel.text = "\(number)"
        
        setupDesign()
    }
    required init?(coder: NSCoder) { fatalError() }

    func setData(number:Int) {
     
        self.number = number
        self.numberLabel.text = "\(number)"
    }
    
    func setupDesign() {
        self.translatesAutoresizingMaskIntoConstraints = false
        textLabel.font = .systemFont(ofSize: 15)
        textLabel.textColor = .label
        textLabel.minimumScaleFactor = 0.6
        textLabel.adjustsFontSizeToFitWidth = true
        
        numberLabel.font = .systemFont(ofSize: 17,weight: .bold)
        numberLabel.textColor = .label
        numberLabel.minimumScaleFactor = 0.6
        numberLabel.adjustsFontSizeToFitWidth = true
        let stack = UIStackView(arrangedSubviews: [numberLabel, textLabel])
        stack.axis = .vertical
        stack.spacing = 5
        stack.distribution = .fillEqually
        stack.alignment = .center
        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}
