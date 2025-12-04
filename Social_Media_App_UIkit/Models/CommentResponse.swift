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
    let post_id:UUID
    let author:UserSummary
    let comment_count:Int
}

struct PostComment:Codable{
    let id:UUID
    let text:String
    let post_id:UUID
    let author:UserSummary
}

