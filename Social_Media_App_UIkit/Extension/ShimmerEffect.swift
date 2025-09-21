//
//  ShimmerEffect.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 9/21/25.
//
import UIKit
extension UIView {
    func startShimmering() {
        //        let light = UIColor.init(white: 0, alpha: 0.1).cgColor
       
        let light = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1).cgColor
        let dark =  UIColor.black.cgColor
        
        let gradientLayer: CAGradientLayer = CAGradientLayer()
      
        gradientLayer.colors = [dark, light,dark]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.55)
        gradientLayer.frame = CGRect(x: -bounds.size.width, y: 0, width: 3*bounds.size.width, height: bounds.size.height)
        gradientLayer.locations = [0.4, 0.5, 0.6]

        
        self.layer.mask = gradientLayer
        
        let animation: CABasicAnimation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [0.0, 0.1, 0.2]
        animation.toValue = [0.8, 0.9, 1]
        animation.duration = 1.5
        animation.repeatCount = HUGE
        
        gradientLayer.add(animation, forKey: "shimmerAnimation")
        
    }

    func stopShimmering() {
        self.layer.mask = nil
    }

}
