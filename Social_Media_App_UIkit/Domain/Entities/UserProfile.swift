//
//  UserProfile.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 10/4/25.
//

import Supabase
import Foundation

// Mirrors your public.users columns you care about in the app
struct UserProfile: Codable, Identifiable, Equatable {
    let id: UUID
    var email: String?
    var username: String
    var full_name: String
    var bio: String?
    var avatar_url: String?
    var follower_count: Int?
    var following_count: Int?
    var post_count: Int?
    var is_verified: Bool?
    var created_at: Date?
}

// Smaller payload for updates/upserts
struct UserProfileUpsert: Codable {
    let id: UUID
    var email: String?
    var username: String
    var full_name: String
    var bio: String?
    var avatar_url: String?
}

extension UserProfile {
    static let mock = UserProfile(
        id: UUID(),
        email: "user@test.com",
        username: "long_username_test_account",
        full_name: "Erling Braut Haaland",
        bio: """
        Erling Braut Haaland is a Norwegian professional footballer who plays as a striker.
        Known for his pace, strength, and finishing ability.
        This bio is intentionally long to test UI truncation and expandable labels.
        """,
        avatar_url: "https://imgs.search.brave.com/eyYUSEwse5wWgfamS4qrwM1EAGCdlRCLGrLSZThAkPU/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly93YWxs/cGFwZXJzLmNvbS9p/bWFnZXMvaGQvZXJs/aW5nLWhhYWxhbmQt/ZnVubnktZmFjZS1y/YThucGhqdGxiZnlz/M3ByLmpwZw",
        follower_count: 9999999,
        following_count: 12,
        post_count: 128,
        is_verified: true,
        created_at: Date(timeIntervalSince1970: 1_700_000_000)
    )
}



// MARK: - Domain
nonisolated
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
struct UserFollowItem: Identifiable, Hashable, Codable, Sendable {
    let id:UUID
    let username: String
    let fullName: String
    let avatarURL: URL?
    let isVerified: Bool
    var isFollowing: Bool // do i follow them
    var isFollower: Bool // do they follow me
    
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case fullName = "full_name"
        case avatarURL = "avatar_url"
        case isVerified = "is_verified"
        case isFollowing = "is_following"
        case isFollower = "is_follower"
    }
    static func mock(id:UUID)->Self{
        UserFollowItem(
           id: id,
           username: "hakim.aliyev",
           fullName: "Hakim Aliyev",
           avatarURL: URL(string: "https://i.pinimg.com/736x/17/9c/52/179c526f10c256d0dcb2ab46e726f6b6.jpg"),
           isVerified: .random(),
           isFollowing: .random(),
           isFollower: .random()
       )
    }
}
