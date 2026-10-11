//
//  SavePostResponce.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 11/29/25.
//

import Foundation

struct SavePostResponse:Codable{
    let action:String
    let is_saved:Bool
    let post_id:UUID
    let user_id:UUID
}
