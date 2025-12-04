//
//  Date+Extension.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 12/4/25.
//

import Foundation



extension Date {
    var iso8601WithMilliseconds: String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.string(from: self)
    }
}

extension Date {
    func timeAgoDisplay() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full    
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}
