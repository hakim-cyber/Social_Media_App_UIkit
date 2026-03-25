//
//  CustomGradientView.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 9/23/25.
//

import UIKit
class CustomGradientView: UIView {
    
    private let gradientLayer = CAGradientLayer()
    
    enum GradientStyle {
        case fadeToBlack
        case fadeToWhite
        case fadeToTransparent
        case custom([CGColor], [NSNumber]?)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradient()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGradient()
    }
    
    convenience init(style: GradientStyle) {
        self.init(frame: .zero)
        applyStyle(style)
    }
    
    private func setupGradient() {
        layer.insertSublayer(gradientLayer, at: 0)
        
        // Default vertical gradient
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        
        // Default fade to black
        applyStyle(.fadeToBlack)
    }
    
    func applyStyle(_ style: GradientStyle) {
        switch style {
        case .fadeToBlack:
            gradientLayer.colors = [
                UIColor.clear.cgColor,
                UIColor.black.withAlphaComponent(0.2).cgColor,
                UIColor.black.withAlphaComponent(0.5).cgColor,
                UIColor.black.withAlphaComponent(0.8).cgColor
            ]
            gradientLayer.locations = [0.0, 0.3, 0.7, 1.0]
            
        case .fadeToWhite:
            gradientLayer.colors = [
                UIColor.clear.cgColor,
                UIColor.white.withAlphaComponent(0.2).cgColor,
                UIColor.white.withAlphaComponent(0.5).cgColor,
                UIColor.white.withAlphaComponent(0.9).cgColor
            ]
            gradientLayer.locations = [0.0, 0.3, 0.7, 1.0]
            
        case .fadeToTransparent:
            gradientLayer.colors = [
                UIColor.black.withAlphaComponent(0.8).cgColor,
                UIColor.black.withAlphaComponent(0.4).cgColor,
                UIColor.clear.cgColor
            ]
            gradientLayer.locations = [0.0, 0.5, 1.0]
            
        case .custom(let colors, let locations):
            gradientLayer.colors = colors
            gradientLayer.locations = locations
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
}
