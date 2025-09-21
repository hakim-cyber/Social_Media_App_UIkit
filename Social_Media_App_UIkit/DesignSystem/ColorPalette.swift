//
//  ColorPalette.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 9/21/25.
//

import UIKit

extension UIColor {
    
    // MARK: - Primary Glassmorphism Colors
    static let glassBackground = UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .dark:
            return UIColor(red: 0.08, green: 0.08, blue: 0.12, alpha: 1.0) // Very dark blue-gray
        default:
            return UIColor(red: 0.95, green: 0.97, blue: 1.0, alpha: 1.0) // Very light blue-white
        }
    }
    
    static let glassSurface = UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .dark:
            return UIColor(red: 0.15, green: 0.15, blue: 0.2, alpha: 0.8) // Semi-transparent dark
        default:
            return UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.7) // Semi-transparent white
        }
    }
    
    static let glassOverlay = UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .dark:
            return UIColor(red: 0.2, green: 0.2, blue: 0.25, alpha: 0.6) // Darker overlay
        default:
            return UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5) // Light overlay
        }
    }
    
    // MARK: - Accent Colors
    static let glassPrimary = UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .dark:
            return UIColor(red: 0.4, green: 0.6, blue: 1.0, alpha: 1.0) // Bright blue
        default:
            return UIColor(red: 0.2, green: 0.4, blue: 0.9, alpha: 1.0) // Deep blue
        }
    }
    
    static let glassSecondary = UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .dark:
            return UIColor(red: 0.7, green: 0.4, blue: 1.0, alpha: 1.0) // Purple
        default:
            return UIColor(red: 0.6, green: 0.3, blue: 0.8, alpha: 1.0) // Dark purple
        }
    }
    
    static let glassAccent = UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .dark:
            return UIColor(red: 0.2, green: 0.9, blue: 0.7, alpha: 1.0) // Bright teal
        default:
            return UIColor(red: 0.1, green: 0.7, blue: 0.6, alpha: 1.0) // Deep teal
        }
    }
    
    // MARK: - Interactive States
    static let glassInteractive = UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .dark:
            return UIColor(red: 0.3, green: 0.3, blue: 0.4, alpha: 0.8)
        default:
            return UIColor(red: 0.9, green: 0.9, blue: 0.95, alpha: 0.9)
        }
    }
    
    static let glassPressed = UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .dark:
            return UIColor(red: 0.4, green: 0.4, blue: 0.5, alpha: 0.9)
        default:
            return UIColor(red: 0.8, green: 0.8, blue: 0.9, alpha: 0.95)
        }
    }
    
    // MARK: - Text Colors
    static let glassPrimaryText = UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .dark:
            return UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1.0)
        default:
            return UIColor(red: 0.1, green: 0.1, blue: 0.15, alpha: 1.0)
        }
    }
    
    static let glassSecondaryText = UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .dark:
            return UIColor(red: 0.7, green: 0.7, blue: 0.75, alpha: 1.0)
        default:
            return UIColor(red: 0.4, green: 0.4, blue: 0.5, alpha: 1.0)
        }
    }
    
    static let glassTertiaryText = UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .dark:
            return UIColor(red: 0.5, green: 0.5, blue: 0.55, alpha: 1.0)
        default:
            return UIColor(red: 0.6, green: 0.6, blue: 0.65, alpha: 1.0)
        }
    }
    
    // MARK: - Status Colors (with glass effect)
    static let glassSuccess = UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .dark:
            return UIColor(red: 0.2, green: 0.8, blue: 0.4, alpha: 0.8)
        default:
            return UIColor(red: 0.1, green: 0.7, blue: 0.3, alpha: 0.8)
        }
    }
    
    static let glassWarning = UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .dark:
            return UIColor(red: 1.0, green: 0.7, blue: 0.2, alpha: 0.8)
        default:
            return UIColor(red: 0.9, green: 0.6, blue: 0.1, alpha: 0.8)
        }
    }
    
    static let glassError = UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .dark:
            return UIColor(red: 1.0, green: 0.4, blue: 0.4, alpha: 0.8)
        default:
            return UIColor(red: 0.9, green: 0.2, blue: 0.2, alpha: 0.8)
        }
    }
    
    // MARK: - Border Colors
    static let glassBorder = UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .dark:
            return UIColor(red: 0.4, green: 0.4, blue: 0.5, alpha: 0.3)
        default:
            return UIColor(red: 0.8, green: 0.8, blue: 0.9, alpha: 0.5)
        }
    }
    
    static let glassHighlightBorder = UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .dark:
            return UIColor(red: 0.6, green: 0.6, blue: 0.7, alpha: 0.6)
        default:
            return UIColor(red: 0.6, green: 0.6, blue: 0.8, alpha: 0.7)
        }
    }
    
    // MARK: - Social Media Specific Colors
    static let glassLike = UIColor(red: 1.0, green: 0.3, blue: 0.5, alpha: 0.9) // Pink/Red
    static let glassComment = UIColor(red: 0.3, green: 0.7, blue: 1.0, alpha: 0.9) // Blue
    static let glassShare = UIColor(red: 0.2, green: 0.8, blue: 0.4, alpha: 0.9) // Green
    static let glassSave = UIColor(red: 0.9, green: 0.6, blue: 0.2, alpha: 0.9) // Orange
    
    static let electricPurple = UIColor(hex:  "#A259FF")
    // MARK: - Convenience Initializers
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var hexFormatted: String = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        
        if hexFormatted.hasPrefix("#") {
            hexFormatted = String(hexFormatted.dropFirst())
        }
        
        assert(hexFormatted.count == 6, "Invalid hex code used.")
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgbValue)
        
        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
}
