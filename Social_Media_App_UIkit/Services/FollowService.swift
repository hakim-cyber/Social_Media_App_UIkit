//
//  FollowService.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 12/20/25.
//

import Foundation
import Supabase

class FollowService{
    private let supabase = SupabaseManager.shared.client
    
    
    func isFollowing(userId: UUID) async throws -> Bool {
        guard let currentUserId = supabase.auth.currentUser?.id else {
            throw SimpleError(message: "User is not authenticated")
        }

        let count: Int = try await supabase
            .from("follows")
            .select("id", count: .exact)
            .eq("follower_id", value: currentUserId)
            .eq("following_id", value: userId)
            .execute()
            .count ?? 0

        return count > 0
    }
}


