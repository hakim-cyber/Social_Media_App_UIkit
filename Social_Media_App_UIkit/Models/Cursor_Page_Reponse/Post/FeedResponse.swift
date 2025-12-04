//
//  FeedResponse.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 12/4/25.
//

import Foundation
// MARK: - Feed Response (matches RPC function structure exactly)
struct FeedResponse: Codable {
    let posts: [Post]
    let hasMore: Bool
    let nextCursor: FeedCursor?
    
    enum CodingKeys: String, CodingKey {
        case posts
        case hasMore = "has_more"
        case nextCursor = "next_cursor"
    }
}
