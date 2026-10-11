//
//  FeedCursor.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 12/4/25.
//

import Foundation


// MARK: - Feed Cursor (for pagination)
struct FeedCursor: Codable {
    let createdAt: Date
    let postId: UUID
    
    enum CodingKeys: String, CodingKey {
        case createdAt = "created_at"
        case postId = "post_id"
    }
}
