//
//  UiView+Extensions.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 10/5/25.
//

import UIKit

extension UIView {
    /// Resizes and pins the view to exactly match its parent view’s bounds
    func resizeToParent(paddings:[CGFloat] = [0,0,0,0]) {
        guard let superview = superview else { return }
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bottomAnchor.constraint(equalTo: superview.bottomAnchor,constant: paddings[safe:0] ?? 0),
            topAnchor.constraint(equalTo: superview.topAnchor,constant: paddings[safe:1] ?? 0),
            leadingAnchor.constraint(equalTo: superview.leadingAnchor,constant: paddings[safe:2] ?? 0) ,
            trailingAnchor.constraint(equalTo: superview.trailingAnchor,constant:paddings[safe:3] ?? 0),
            
        ])
    }
}

extension UIView {
    /// Applies an ultra-thin material background with optional rounded corners.
  
    func applyUltraThinMaterial( blurStyle: UIBlurEffect.Style = .systemUltraThinMaterial){
        // Add blur effect
           let blurEffect = UIBlurEffect(style: blurStyle)
           let blurView = UIVisualEffectView(effect: blurEffect)
           blurView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(blurView)
           
           NSLayoutConstraint.activate([
               blurView.topAnchor.constraint(equalTo: self.topAnchor),
               blurView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
               blurView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
               blurView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
           ])
    }
    
}
