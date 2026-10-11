//
//  Int+Extension.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 10/14/25.
//

import Foundation

extension Int {
    /// Converts numbers like 1200 → 1.2K, 1_000_000 → 1M, etc.
    var shortFormatted: String {
        let num = Double(self)
        let thousand = num / 1000
        let million = num / 1_000_000
        let billion = num / 1_000_000_000

        switch num {
        case 1_000_000_000...:
            return String(format: "%.1fB", billion)
        case 1_000_000...:
            return String(format: "%.1fM", million)
        case 1_000...:
            return String(format: "%.1fK", thousand)
        default:
            return "\(self)"
        }
    }
}
