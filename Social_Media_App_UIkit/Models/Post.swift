//
//  Post.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 10/4/25.
//

import Foundation

// MARK: - Domain
struct UserSummary: Identifiable, Hashable, Codable {
    let id: UUID
    let username: String
    let fullName: String
    let avatarURL: URL?
    let isVerified: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case username
        case fullName = "full_name"
        case avatarURL = "avatar_url"
        case isVerified = "is_verified"
    }
}
struct Post: Identifiable, Hashable, Codable, Sendable {
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

    enum CodingKeys: String, CodingKey {
        case id
        case caption
        case imageURL = "image_url"
        case location
        case likeCount = "like_count"
        case commentCount = "comment_count"
        case createdAt = "created_at"
        case author
        case isLiked = "is_liked"
        case isSaved = "is_saved"
    }

    // ✅ Custom decoding with fallback defaults
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Non-optional with safe defaults
        self.id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        self.caption = try container.decodeIfPresent(String.self, forKey: .caption) ?? ""
        self.imageURL = try container.decodeIfPresent(URL.self, forKey: .imageURL) ?? URL(string: "https://example.com/placeholder.jpg")!
        self.location = try container.decodeIfPresent(String.self, forKey: .location)
        self.likeCount = try container.decodeIfPresent(Int.self, forKey: .likeCount) ?? 0
        self.commentCount = try container.decodeIfPresent(Int.self, forKey: .commentCount) ?? 0
        self.createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date()

        // Nested struct — fallback to empty author if missing
        self.author = try container.decodeIfPresent(UserSummary.self, forKey: .author)
        ?? UserSummary(id: UUID(), username: "Unknown", fullName: "Unknown", avatarURL: nil, isVerified: false)

        // Booleans with defaults
        self.isLiked = try container.decodeIfPresent(Bool.self, forKey: .isLiked) ?? false
        self.isSaved = try container.decodeIfPresent(Bool.self, forKey: .isSaved) ?? false
    }
}
