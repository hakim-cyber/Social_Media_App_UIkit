//
//  CommentCursor.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 12/4/25.
//

import Foundation

struct CommentCursor:Codable,Hashable{
    let createdAt:Date
    let commentId:UUID
    
    enum CodingKeys:String,CodingKey{
        case createdAt = "created_at"
        case commentId = "comment_id"
    }
}
