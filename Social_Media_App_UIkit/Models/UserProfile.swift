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
