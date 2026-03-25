//
//  CommentPage.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 12/4/25.
//

import Foundation

struct CommentPageResponse:Codable{
    let comments:[PostComment]
    let nextCursor:CommentCursor?
    
    enum CodingKeys:String,CodingKey{
        case comments
        case nextCursor = "next_cursor"
    }
}
