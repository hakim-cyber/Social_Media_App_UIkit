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
    @Published  var target: FollowerListTarget = .following
    
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
    let isCurrentUser:Bool
    
    private var followingUsers = Set<UUID>()
  
    let followService:FollowService
    init(
           target: FollowerListTarget,
           selectedUser:UserProfile,
           isCurrentUser:Bool = false,
           followService:FollowService = .init()
       ) {
        self.target = target
           self.selectedUser = selectedUser
           self.isCurrentUser = isCurrentUser
           self.followService = followService
    }
    
    func loadMoreIfNeeded() {
        switch target {
        case .following:
            Task{
                await  loadMoreFollowings()
            }
        case .followers:
            Task{
                await  loadMoreFollowers()
            }
        }
    }
    func start() async{
        self.followerCount = selectedUser.follower_count ?? 0
        self.followingCount = selectedUser.following_count ?? 0
        await loadInitiaFollowers()
        await loadInitialFollowings()
         
    }
    func loadInitiaFollowers() async{
        let userID = selectedUser.id
        guard !self.isLoadingFollowers else{return}
      
        isLoadingFollowers = true
        defer{isLoadingFollowers = false}
        
        do{
            let page:FollowerListResponse = try await followService.getFollowers(userID:userID, limit: pageSize )
            self.followers = page.users
            followersCursor = page.nextCursor
        }catch{
            errorMessage = "Failed to load followers \(error.localizedDescription)"
        }
    }
    
    func loadMoreFollowers()async{
        let userID = selectedUser.id
        guard !isLoadingFollowers,let cursor = followersCursor else{return}
        isLoadingFollowers = true
        defer{isLoadingFollowers = false}
        
        do{
            let page:FollowerListResponse = try await  followService.getFollowers(userID:userID, limit: pageSize,beforeCursor: cursor)
            appendDedup(page.users, to: &followers)
            followersCursor = page.nextCursor
        }catch{
            errorMessage = "Failed to load more followers  \(error.localizedDescription)"
        }
    }
    func loadInitialFollowings() async{
        let userID = selectedUser.id
        guard !self.isLoadingFollowings else{return}
      
        isLoadingFollowings = true
        defer{isLoadingFollowings = false}
        
        do{
            let page:FollowerListResponse = try await followService.getFollowings(userID:userID, limit: pageSize )
            self.followings = page.users
            followingsCursor = page.nextCursor
        }catch{
            errorMessage = "Failed to load followings \(error.localizedDescription)"
        }
    }
    
    func loadMoreFollowings()async{
        let userID = selectedUser.id
        guard !isLoadingFollowings,let cursor = followingsCursor else{return}
        isLoadingFollowings = true
        defer{isLoadingFollowings = false}
        
        do{
            let page:FollowerListResponse = try await  followService.getFollowings(userID:userID, limit: pageSize,beforeCursor: cursor)
            appendDedup(page.users, to: &followings)
            followingsCursor = page.nextCursor
        }catch{
            errorMessage = "Failed to load more followings  \(error.localizedDescription)"
        }
    }
  
    private func appendDedup(_ new: [UserFollowItem], to array: inout [UserFollowItem]) {
        let existing = Set(array.map(\.id))
        let filtered = new.filter { !existing.contains($0.id) }
        array.append(contentsOf: filtered)
    }
    
}
