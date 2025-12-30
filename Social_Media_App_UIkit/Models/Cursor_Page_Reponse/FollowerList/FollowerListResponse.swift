//
//  FollowerListResponse.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 12/30/25.
//

import Foundation

struct FollowerListResponse: Codable {
    let users: [UserFollowItem]
    let hasMore: Bool
    let nextCursor: FollowerListCursor?
    
    enum CodingKeys: String, CodingKey {
        case users
        case hasMore = "has_more"
        case nextCursor = "next_cursor"
    }
}
