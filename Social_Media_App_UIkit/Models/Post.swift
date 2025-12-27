//
//  Post.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 10/4/25.
//

import Foundation

// MARK: - Domain
struct UserSummary: Identifiable, Hashable, Codable, Sendable {
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
    static let mockUser = UserSummary(
        id: UUID(),
        username: "hakim.aliyev",
        fullName: "Hakim Aliyev",
        avatarURL: URL(string: "https://i.pinimg.com/736x/17/9c/52/179c526f10c256d0dcb2ab46e726f6b6.jpg"),
        isVerified: true
    )
    static func mock(id:UUID)->Self{
        UserSummary(
           id: id,
           username: "hakim.aliyev",
           fullName: "Hakim Aliyev",
           avatarURL: URL(string: "https://i.pinimg.com/736x/17/9c/52/179c526f10c256d0dcb2ab46e726f6b6.jpg"),
           isVerified: true
       )
    }
}
nonisolated
struct Post: Identifiable, Hashable, Codable, Sendable {
    var id: UUID
    var caption: String
    let imageURL: URL
    let location: String?
    var likeCount: Int
    var commentCount: Int
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
        avatarURL: URL(string: "https://i.pinimg.com/736x/17/9c/52/179c526f10c256d0dcb2ab46e726f6b6.jpg"),
        isVerified: true
    )
    static  let mockCaption = """
    ✨ Some nights feel like soft pages from a dream — the kind that smells like coffee, rain, and unfinished thoughts. The city lights blur into watercolor, and for a moment, everything feels beautifully uncertain. 🌙

    I’m learning that growth doesn’t always look loud. Sometimes it’s silent mornings, small steps, and choosing peace over perfection. 🕊️

    Here’s to the in-between — where we outgrow old versions of ourselves, and quietly bloom into something new. 🌸
    """

    static  let mockPost = Post(
        caption: mockCaption,
        imageURL: URL(string: "https://i.pinimg.com/736x/c4/e8/d0/c4e8d07cfa77ecce2ad5c84041d8643f.jpg")!,
        location: "Baku, Azerbaijan",
        likeCount: 1280000,
        commentCount: 1400,
        author: mockUser,
        isLiked: true
    )
}

struct RawPost: Codable, Sendable {
    let id: UUID
    let caption: String
    let image_url: URL
    let location: String?
    let like_count: Int
    let comment_count: Int
    let created_at: Date
    let author_id: UUID
}

