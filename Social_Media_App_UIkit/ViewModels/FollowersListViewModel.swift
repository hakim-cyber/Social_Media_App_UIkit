//
//  FollowersListViewModel.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 12/29/25.
//

import UIKit
import Combine
enum FollowerListTarget{
    case following
    case followers
}
class FollowersListViewModel{
    @Published private(set) var target: FollowerListTarget = .following
    
    @Published private(set) var followerCount:Int = 0
    @Published private(set) var followingCount:Int = 0
    
    @Published private(set) var errorMessage: String? = nil
    
    
    @Published private(set) var followings: [UserFollowItem] = []
    @Published private(set) var followers: [UserFollowItem] = []
    
    
    private var followingsCursor: FollowerListCursor?
    private var followersCursor: FollowerListCursor?
    
    @Published private(set) var isLoadingFollowings = false
    @Published private(set) var isLoadingFollowers = false
    
    
    var activeFollow: [UserFollowItem] {
        switch target {
        case .following:
            return followings
        case .followers:
            return followers
        }
            
        }
    
    private let pageSize =  20
    
    let selectedUser:UserProfile
    
    
    private var followingUsers = Set<UUID>()
  
    init(
           target: FollowerListTarget,
           selectedUser:UserProfile
       ) {
        self.target = target
           self.selectedUser = selectedUser
           self.followerCount = selectedUser.follower_count ?? 0
           self.followingCount = selectedUser.following_count ?? 0
    }
    
    
}
