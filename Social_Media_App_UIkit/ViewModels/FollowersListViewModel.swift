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
    // button actions
    private func updateList(_ userID: UUID, _ update: (inout UserFollowItem) -> Void) {
        if let i = followings.firstIndex(where: { $0.id == userID }) {
            update(&followings[i])
        }
        if let i = followers.firstIndex(where: { $0.id == userID }) {
            update(&followers[i])
        }
    }
    func toggleFollow(for userId: UUID, desiredState: Bool) {
        guard !followingUsers.contains(userId) else { return }
        followingUsers.insert(userId)

        // 🔹 Save old values (for rollback)
        let old = activeFollow.first { $0.id == userId }

        // 🔹 Optimistic UI update
        updateList(userId) { user in
            user.isFollowing = desiredState
        }
        self.followingCount += !desiredState ? -1 : 1

        Task { [weak self] in
            guard let self else { return }
            defer { self.followingUsers.remove(userId) }

            do {
                let resp:FollowResponse = try await self.followService.toggleFollow(userId: userId)
            } catch {
                // 🔴 Rollback on failure
                if let old {
                    self.updateList(userId) { user in
                        user = old
                    }
                    
                }
                self.followingCount -= !desiredState ? -1 : 1
                self.errorMessage = "Follow failed"
            }
        }
    }
    func removeFollower(userId:UUID){
        guard let old = followers.first (where:{ $0.id == userId } )else{return}
        guard !followingUsers.contains(userId) else { return }
        followingUsers.insert(userId)

        // 🔹 Save old values (for rollback)
      

        // 🔹 Optimistic UI update
        updateList(userId) { user in
            user.isFollower = false
        }
        self.followerCount -= 1

        Task { [weak self] in
            guard let self else { return }
            defer { self.followingUsers.remove(userId) }

            do {
                let resp:RemoveFollowResponse = try await self.followService.deleteFollower(targetUserID: userId)
                if !resp.removed{
                 
                        self.updateList(userId) { user in
                            user = old
                        }
                    self.followerCount += 1
                }
            } catch {
                // 🔴 Rollback on failure
              
                    self.updateList(userId) { user in
                        user = old
                    }
                self.followerCount += 1
                
                self.errorMessage = "Remove Follower failed"
            }
        }
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
    func loadSelectedInitialData() async{
        switch target {
        case .following:
            Task{
                await  loadInitialFollowings()
            }
        case .followers:
            Task{
                await  loadInitiaFollowers()
            }
        }
    }
    func start() async{
        self.followerCount = selectedUser.follower_count ?? 0
        self.followingCount = selectedUser.following_count ?? 0
        await loadSelectedInitialData()
         
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
