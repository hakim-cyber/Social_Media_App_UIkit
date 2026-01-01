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
    func toggleFollow(userId: UUID) async throws -> FollowResponse{
        let response: FollowResponse = try await supabase
            .rpc("toggle_follow", params: [
                "target_user_id_param": AnyJSON(userId.uuidString)
            ])
            .execute()
            .value

        return response
    }
    
    func getFollowers(
        userID:UUID,
        limit:Int = 20,
        beforeCursor:FollowerListCursor? = nil
    )async throws -> FollowerListResponse{
        var parameters: [String: AnyJSON] = [
            "target_user_id": try AnyJSON(userID),
            "limit_param": try AnyJSON(limit),
            
        ]
        if let beforeCursor{
            // Add cursor parameters if available
             let beforeCreatedAt = beforeCursor.createdAt.iso8601WithMilliseconds
                parameters["before_created_at"] =  try AnyJSON(beforeCreatedAt)
            
            let beforeId = beforeCursor.userID.uuidString
                parameters["before_user_id"] = try AnyJSON(beforeId)
            
        }
        // Call RPC function
        let response: FollowerListResponse = try await supabase
            .rpc("get_followers_cursor", params: parameters)
            .execute()
            .value

        return response
    }
    func getFollowings(
        userID:UUID,
        limit:Int = 20,
        beforeCursor:FollowerListCursor? = nil
    )async throws -> FollowerListResponse{
        var parameters: [String: AnyJSON] = [
            "target_user_id": try AnyJSON(userID),
            "limit_param": try AnyJSON(limit),
            
        ]
        if let beforeCursor{
            // Add cursor parameters if available
             let beforeCreatedAt = beforeCursor.createdAt.iso8601WithMilliseconds
                parameters["before_created_at"] =  try AnyJSON(beforeCreatedAt)
            
            let beforeId = beforeCursor.userID.uuidString
                parameters["before_user_id"] = try AnyJSON(beforeId)
            
        }
        // Call RPC function
        let response: FollowerListResponse = try await supabase
            .rpc("get_following_cursor", params: parameters)
            .execute()
            .value

        return response
    }
}


