//
//  Follow.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 12/22/25.
//

import Foundation

struct FollowResponse:Codable{
    let action:String
    let is_following:Bool
    let target_user_id:UUID
    let user_id:UUID
    let target_follower_count:Int
    let my_following_count:Int
    
}


/*
 result := json_build_object(
             'action', 'followed',
             'is_following', TRUE,
             'target_user_id', target_user_id_param,
             'user_id', user_id_param,
             'target_follower_count', new_target_follower_count,
             'my_following_count', new_my_following_count
         );
 */
