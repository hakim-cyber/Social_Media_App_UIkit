//
//  RoundedImageViewWithCaching.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 10/12/25.
//

import UIKit
import Kingfisher

final class RoundedImageView: UIImageView {
    
    // MARK: - Configuration
    private let isCircular: Bool
    private let cornerRadiusValue: CGFloat
    private let maskedCorners: CACornerMask
    private var currentURL: URL?
    
    // MARK: - Init
    init(
        url: URL?,
        isCircular: Bool = true,
        cornerRadius: CGFloat = 12,
        maskedCorners:CACornerMask = [.layerMaxXMaxYCorner,.layerMinXMaxYCorner,.layerMinXMinYCorner,.layerMaxXMinYCorner],
        borderWidth: CGFloat = 0,
        borderColor: UIColor = .clear
    ) {
        self.isCircular = isCircular
        self.cornerRadiusValue = cornerRadius
        self.maskedCorners = maskedCorners
        super.init(frame: .zero)
        
        translatesAutoresizingMaskIntoConstraints = false
        clipsToBounds = true
        contentMode = .scaleAspectFill
        layer.maskedCorners = maskedCorners
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor.cgColor
        backgroundColor = .glassBackground
        
        if let url = url {
            setImage(url: url)
        } else {
            image = nil
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Image Loading
    func setImage(url: URL) {
        currentURL = url
        kf.setImage(
            with: url,
            options: [
                .transition(.fade(0.25)),
                .cacheOriginalImage,
                .backgroundDecode
            ]
        )
    }
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        if isCircular {
            layer.cornerRadius = min(bounds.width, bounds.height) / 2
        } else {
            layer.cornerRadius = cornerRadiusValue
        }
    }
}
