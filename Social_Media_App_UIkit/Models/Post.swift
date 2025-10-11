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
    init(
            id: UUID = UUID(),
            caption: String,
            imageURL: URL,
            location: String? = nil,
            likeCount: Int = 0,
            commentCount: Int = 0,
            createdAt: Date = Date(),
            author: UserSummary,
            isLiked: Bool = false,
            isSaved: Bool = false
        ) {
            self.id = id
            self.caption = caption
            self.imageURL = imageURL
            self.location = location
            self.likeCount = likeCount
            self.commentCount = commentCount
            self.createdAt = createdAt
            self.author = author
            self.isLiked = isLiked
            self.isSaved = isSaved
        }
    
    
    static let mockUser = UserSummary(
        id: UUID(),
        username: "hakim",
        fullName: "Hakim Aliyev",
        avatarURL: URL(string: "https://i.pinimg.com/736x/3e/dd/95/3edd95bdf7f5c2eddfe42c499fba05ed.jpg"),
        isVerified: true
    )

    static  let mockPost = Post(
        caption: "This is my favorite photo 🌅",
        imageURL: URL(string: "https://i.pinimg.com/1200x/e2/97/de/e297de3f7c348cec55f3e6444ed57b40.jpg")!,
        location: "Baku, Azerbaijan",
        likeCount: 128,
        commentCount: 14,
        author: mockUser,
        isLiked: true
    )
}
