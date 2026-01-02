//
//  CommentResponse.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 11/30/25.
//
import Foundation

struct CommentCreateResponse:Codable{
    let id:UUID
    let text:String
    let created_at:Date
    let post_id:UUID
    let author:UserSummary
    let comment_count:Int
}
nonisolated
struct PostComment:Identifiable, Hashable, Codable, Sendable {
    let id:UUID
    let text:String
    let created_at:Date
    let post_id:UUID
    let author:UserSummary
}


struct CommentDeleteResponse:Codable{
    let removed:Bool
    let comment_id:UUID
    let post_id:UUID
    
    let comment_count:Int
}
