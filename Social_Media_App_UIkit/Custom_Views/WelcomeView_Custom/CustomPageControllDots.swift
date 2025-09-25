//
//  CustomPageControllDots.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 9/23/25.
//

import UIKit
class CustomPageControlDots: UIStackView {
    
    private var indicators: [UIView] = []
    private let dotSize: CGFloat = 8
    private let activeDotSize: CGFloat = 12
    var previousPage:Int = 0
    var numberOfPages: Int = 0 {
        willSet{previousPage = numberOfPages}
        didSet { setupIndicators() }
    }
    
    var currentPage: Int = 0 {
        didSet { updateIndicators() }
    }
    var dotWidthConstraints:[NSLayoutConstraint] = []
    private func setupIndicators() {
        indicators.forEach { $0.removeFromSuperview() }
        indicators = []
        
        for _ in 0..<numberOfPages {
            let dot = UIView()
            dot.backgroundColor = .tertiaryLabel
            dot.layer.cornerRadius = dotSize / 2
            dot.translatesAutoresizingMaskIntoConstraints = false
          
                
               
           
            dot.heightAnchor.constraint(equalToConstant: dotSize).isActive = true
            
           
            
            let widthConstraint = dot.widthAnchor.constraint(equalToConstant: dotSize)
            widthConstraint.isActive = true
            dotWidthConstraints.append(widthConstraint)
            
            addArrangedSubview(dot)
            indicators.append(dot)
        }
        spacing = 4
        alignment = .top
        distribution = .equalSpacing
        
        updateIndicators()
    }
    
    private func updateIndicators() {
        for (index, dot) in indicators.enumerated() {
            if index == currentPage {
                UIView.animate(withDuration: 0.3) {
                    dot.backgroundColor = UIColor.electricPurple
                    self.dotWidthConstraints[index].constant = self.dotSize * 2.3
                    dot.layer.cornerRadius = self.dotSize * 0.4
                    self.layoutIfNeeded()
                }
            } else {
                UIView.animate(withDuration: 0.3) {
                    dot.backgroundColor = .tertiaryLabel
                    dot.layer.cornerRadius = self.dotSize / 2
                    self.dotWidthConstraints[index].constant = self.dotSize
                    self.layoutIfNeeded()
                }
            }
        }
    }
}
