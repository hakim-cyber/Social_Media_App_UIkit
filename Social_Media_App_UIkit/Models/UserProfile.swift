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
