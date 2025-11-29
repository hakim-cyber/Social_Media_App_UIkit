//
//  CommentResponse.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 11/30/25.
//
import Foundation

struct CommentResponse:Codable{
    let id:UUID
    let text:String
    let post_id:UUID
    let author:UserSummary
    let comment_count:Int
}

/*
 // MARK: - Domain
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
 }
 */
