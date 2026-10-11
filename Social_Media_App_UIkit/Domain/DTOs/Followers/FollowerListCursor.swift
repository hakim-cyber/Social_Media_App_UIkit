//
//  FollowerListCursor.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 12/30/25.
//

import Foundation

// MARK: - Feed Cursor (for pagination)
struct FollowerListCursor: Codable {
    let createdAt: Date
    let userID: UUID
    
    enum CodingKeys: String, CodingKey {
        case createdAt = "created_at"
        case userID = "user_id"
    }
}
