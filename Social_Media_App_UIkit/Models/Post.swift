//
//  Post.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 10/4/25.
//

import Foundation
// MARK: - Domain
struct UserSummary: Identifiable, Hashable {
    let id: UUID
    let username: String
    let fullName: String
    let avatarURL: URL?
    let isVerified: Bool
}

struct Post: Identifiable, Hashable {
    let id: UUID
    let caption: String
    let imageURL: URL
    let location: String?
    let likeCount: Int
    let commentCount: Int
    let createdAt: Date
    let author: UserSummary
    var isLiked: Bool
    var isSaved: Bool
}
