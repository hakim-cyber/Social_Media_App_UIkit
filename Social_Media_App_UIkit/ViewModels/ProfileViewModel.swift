//
//  ProfileViewModel.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 12/20/25.
//

import Foundation
import Combine
import Supabase

enum ProfileTarget: Equatable {
    case me
    case user(id: UUID)
}
enum ProfileTab: Equatable {
    case savedPosts
    case posts
}

class ProfileViewModel:ObservableObject{
    @Published private(set) var profile: UserProfile?
    @Published private(set) var isFollowing: Bool = false
    @Published private(set) var errorMessage: String? = nil
    
    
    @Published private(set) var userPosts: [Post] = []
    @Published private(set) var savedPosts: [Post] = []
    
    private var userPostsCursor: FeedCursor?
    private var savedPostsCursor: FeedCursor?

    @Published private(set) var isLoadingUserPosts = false
    @Published private(set) var isLoadingSavedPosts = false
    
    
    @Published private(set) var selectedTab: ProfileTab = .posts
    
    private let pageSize =  20
    
    let target: ProfileTarget
    var userID:UUID?
    let isCurrentUser:Bool
    
    let profileService: ProfileService
    let followService: FollowService
    let postQueryService:PostQueryService = .init()
    init(
           target: ProfileTarget,
           profileService: ProfileService = .init(),
           followService: FollowService = .init()
       ) {
        self.target = target
        switch target {
        case .me:
            self.userID = UserSessionService.shared.currentUser?.id
            isCurrentUser = true
        case .user(let id):
            self.userID = id
            isCurrentUser = false
        }
           self.profileService = profileService
           self.followService = followService
      
           
    }
    func start() async{
         await loadProfile()
         await loadInitialPosts()
        if self.isCurrentUser {await loadInitialSavedPosts()}
         
    }
    func loadProfile() async  {
        guard let userID else {
            self.errorMessage = "User not found"
            return
        }
        
        do{
            let profile = try await profileService.fetchUserProfile(id: userID)
            self.profile = profile
            
            if !self.isCurrentUser {
               isFollowing = try await followService.isFollowing(userId: userID)
            }
        }catch{
            self.errorMessage = error.localizedDescription
        }
    }
    func loadInitialPosts() async{
        guard let userID else{return}
        guard !self.isLoadingUserPosts else{return}
      
        isLoadingUserPosts = true
        defer{isLoadingUserPosts = false}
        
        do{
            let page:FeedResponse = try await postQueryService.fetchPostsForUser(userID:userID, limit: pageSize )
            self.userPosts = page.posts
            userPostsCursor = page.nextCursor
        }catch{
            errorMessage = "Failed to load user posts \(error.localizedDescription)"
        }
    }
    
    func loadMorePosts()async{
        guard let userID else{return}
        guard !isLoadingUserPosts,let cursor = userPostsCursor else{return}
        isLoadingUserPosts = true
        defer{isLoadingUserPosts = false}
        
        do{
            let page:FeedResponse = try await  postQueryService.fetchPostsForUser(userID:userID, limit: pageSize,beforeCreatedAt: cursor.createdAt,beforeId:  cursor.postId)
            appendDedup(page.posts, to: &userPosts)
            userPostsCursor = page.nextCursor
        }catch{
            errorMessage = "Failed to load more user posts \(error.localizedDescription)"
        }
    }
    func loadInitialSavedPosts() async{
        guard !isLoadingSavedPosts else{return}
        isLoadingSavedPosts = true
        defer{isLoadingSavedPosts = false}
        
        do{
            let page:FeedResponse = try await postQueryService.fetchSavedPosts(limit: pageSize)
            savedPosts = page.posts
            savedPostsCursor = page.nextCursor
        }catch{
            errorMessage = "Failed to load saved posts \(error.localizedDescription)"
        }
    }
    
    func loadMoreSavedPosts()async{
        guard !isLoadingSavedPosts,let cursor = savedPostsCursor else{return}
        isLoadingSavedPosts = true
        defer{isLoadingSavedPosts = false}
        
        do{
            let page:FeedResponse = try await postQueryService.fetchSavedPosts(limit: pageSize,beforeCreatedAt: cursor.createdAt,beforeId:  cursor.postId)
            appendDedup(page.posts, to: &savedPosts)
            savedPostsCursor = page.nextCursor
        }catch{
            errorMessage = "Failed to load more saved posts \(error.localizedDescription)"
        }
    }
    
    private func appendDedup(_ new: [Post], to array: inout [Post]) {
        let existing = Set(array.map(\.id))
        let filtered = new.filter { !existing.contains($0.id) }
        array.append(contentsOf: filtered)
    }
}
