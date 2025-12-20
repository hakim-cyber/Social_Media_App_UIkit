//
//  PostService.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 10/7/25.
//

import UIKit
import Supabase



final class PostActionService{
    private let supabase = SupabaseManager.shared.client
    
  
}



// PostService
extension  PostActionService {
   
    /// Upload a post image; typically immutable (upsert=false). Prefer unique filename.
    func uploadPostImage(_ image: UIImage, userId: UUID) async throws -> (path: String, url: String) {
        let svc = SupabaseStorageService()
        let res = try await svc.uploadImage(
            image,
            userId: userId,
            bucket: .postImages,
            fileName: nil,                 // auto-generate unique name
            jpegQuality: 1.0,
            upsert: false,                 // do not overwrite post images
            publicBucket: true             // or false if your post_images bucket is private
        )
        return (res.path, res.url.absoluteString)
    }
    func createPost(caption: String?, image: UIImage, location: String?) async throws -> Post {
        let session = try await supabase.auth.session
        let (_, imageURL) = try await uploadPostImage(image, userId: session.user.id)
        // Build dynamic params using AnyJSON
        var params: [String: AnyJSON] = [
            "image_url_param": .string(imageURL)
        ]
        
        // Add optional ones only if non-nil
        if let caption {
            params["caption_param"] = .string(caption)
        }
        if let location {
            params["location_param"] = .string(location)
        }

        // Call the RPC and decode into your Post model
        let post: Post = try await supabase
            .rpc("create_post", params: params)
            .single()                // Expect a single JSON row/object back
            .execute()
            .value// Decode into your domain model

        print(post)
        return post
    }
    
    // Button Actions on Post
    func addLikeToPost(postId: UUID) async throws -> LikeResponse {
        let response: LikeResponse = try await supabase
            .rpc("toggle_like", params: [
                "post_id_param": AnyJSON(postId.uuidString)
            ])
            .execute()
            .value

        return response
    }
    func savePost(postId: UUID) async throws -> SavePostResponse {
        let response: SavePostResponse = try await supabase
            .rpc("toggle_save", params: [
                "post_id_param": AnyJSON(postId.uuidString)
            ])
            .execute()
            .value

        return response
    }
   

}
