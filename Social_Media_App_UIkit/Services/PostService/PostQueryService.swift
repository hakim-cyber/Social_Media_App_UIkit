//
//  PostQueryService.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 12/21/25.
//
import Supabase
import Foundation

final class PostQueryService{
    private let supabase = SupabaseManager.shared.client
    
    
    func fetchPostsForUser(
        userID: UUID,
        limit: Int = 20,
        
        beforeCreatedAt: Date? = nil,
        beforeId: UUID? = nil
    ) async throws -> FeedResponse {
        // Build parameters
        var parameters: [String: AnyJSON] = [
            "user_id_param": try AnyJSON(userID),
            "limit_param": try AnyJSON(limit),
          
        ]
        
        // Add cursor parameters if available
        if let beforeCreatedAt = beforeCreatedAt {
            parameters["before_created_at"] =  try AnyJSON(beforeCreatedAt.iso8601WithMilliseconds)
        }
        
        if let beforeId = beforeId {
            parameters["before_id"] = try AnyJSON(beforeId.uuidString)
        }
        
        // Call RPC function
        let response: FeedResponse = try await supabase
            .rpc("get_user_posts_cursor", params: parameters)
            .execute()
            .value
        
        return response
    }
    
    func fetchSavedPosts(
        limit: Int = 20,
        
        beforeCreatedAt: Date? = nil,
        beforeId: UUID? = nil
    ) async throws -> FeedResponse {
        // Build parameters
        var parameters: [String: AnyJSON] = [
            "limit_param": try AnyJSON(limit)
        ]
        
        // Add cursor parameters if available
        if let beforeCreatedAt = beforeCreatedAt {
            parameters["before_created_at"] =  try AnyJSON(beforeCreatedAt.iso8601WithMilliseconds)
        }
        
        if let beforeId = beforeId {
            parameters["before_id"] = try AnyJSON(beforeId.uuidString)
        }
        
        // Call RPC function
        let response: FeedResponse = try await supabase
            .rpc("get_saved_posts_cursor", params: parameters)
            .execute()
            .value
        
        return response
    }
    func fetchLikedPosts(
        userID: UUID,
        limit: Int = 20,
        
        beforeCreatedAt: Date? = nil,
        beforeId: UUID? = nil
    ) async throws -> FeedResponse {
        // Build parameters
        var parameters: [String: AnyJSON] = [
            "target_user_id" :try AnyJSON(userID),
            "limit_param": try AnyJSON(limit)
        ]
        
        // Add cursor parameters if available
        if let beforeCreatedAt = beforeCreatedAt {
            parameters["before_created_at"] =  try AnyJSON(beforeCreatedAt.iso8601WithMilliseconds)
        }
        
        if let beforeId = beforeId {
            parameters["before_id"] = try AnyJSON(beforeId.uuidString)
        }
        
        // Call RPC function
        let response: FeedResponse = try await supabase
            .rpc("get_liked_posts_cursor", params: parameters)
            .execute()
            .value
        
        return response
    }
  
}


