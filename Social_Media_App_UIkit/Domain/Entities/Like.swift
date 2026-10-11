//
//  Like.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 11/23/25.
//

import Foundation


struct LikeResponse:Codable{
    let action:String
    let is_liked:Bool
    let like_count:Int
    let post_id:UUID
    let user_id:UUID
}
