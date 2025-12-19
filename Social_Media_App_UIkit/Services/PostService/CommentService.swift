//
//  CommentService.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 12/4/25.
//

import Supabase
import Foundation


final class CommentService{
    
    private let supabase = SupabaseManager.shared.client
    
    
    
    func createComment(text: String, postID: UUID) async throws -> CommentCreateResponse {
        let response : CommentCreateResponse = try await supabase
            .rpc("create_comment", params: [
                "text_param":  AnyJSON(text),
                "post_id_param": AnyJSON(postID.uuidString)
            ])
            .execute()
            .value
        
        return response
    }
    
    
    func fetchComments(
        postId:UUID,
        limit:Int = 20,
        beforeCursor:CommentCursor? = nil
    )async throws -> CommentPageResponse{
        var parameters: [String: AnyJSON] = [
            "post_id_param": try AnyJSON(postId),
            "limit_param": try AnyJSON(limit),
            
        ]
        if let beforeCursor{
            // Add cursor parameters if available
             let beforeCreatedAt = beforeCursor.createdAt.iso8601WithMilliseconds
                parameters["before_created_at"] =  try AnyJSON(beforeCreatedAt)
            
             let beforeId = beforeCursor.commentId.uuidString
                parameters["before_id"] = try AnyJSON(beforeId)
            
        }
        // Call RPC function
        let response: CommentPageResponse = try await supabase
            .rpc("get_post_comments_cursor", params: parameters)
            .execute()
            .value

        return response
    }
}
