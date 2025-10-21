//
//  FeedService.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 10/20/25.
//
import Supabase
import Foundation
import Combine

final class FeedService {
    private let client = SupabaseManager.shared.client
    
    func loadGlobalFeed(
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
        let response: FeedResponse = try await client
            .rpc("get_global_feed_cursor", params: parameters)
            .execute()
            .value
        
        return response
    }
    
}

// MARK: - Feed Response (matches RPC function structure exactly)
struct FeedResponse: Codable {
    let posts: [Post]
    let hasMore: Bool
    let nextCursor: FeedCursor?
    
    enum CodingKeys: String, CodingKey {
        case posts
        case hasMore = "has_more"
        case nextCursor = "next_cursor"
    }
}
// MARK: - Feed Cursor (for pagination)
struct FeedCursor: Codable {
    let createdAt: Date
    let postId: UUID
    
    enum CodingKeys: String, CodingKey {
        case createdAt = "created_at"
        case postId = "post_id"
    }
}

extension Date {
    var iso8601WithMilliseconds: String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.string(from: self)
    }
}
