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
enum ProfileTab: Hashable {
    case posts
    case liked
    case saved
}

class ProfileViewModel:ObservableObject{
    @Published private(set) var selectedTab: ProfileTab = .posts
    
    @Published private(set) var profile: UserProfile?
    @Published private(set) var isFollowing: Bool = false
    @Published private(set) var errorMessage: String? = nil
    
    
    @Published private var tryingToFollow: Bool = false
    
    @Published private(set) var posts: [Post] = []
    @Published private(set) var likedPosts: [Post] = []
    @Published private(set) var savedPosts: [Post] = []
    
    private var userPostsCursor: FeedCursor?
    private var likedPostsCursor: FeedCursor?
    private var savedPostsCursor: FeedCursor?

    @Published private(set) var isLoadingUserPosts = false
    @Published private(set) var isLoadingLikedPosts = false
    @Published private(set) var isLoadingSavedPosts = false
    
   
    @Published private(set) var profileCount: ProfileCounts = .init(liked: 0, saved: 0)
    
    var activePosts: [Post] {
            switch selectedTab {
            case .posts: return posts
            case .liked: return likedPosts
            case .saved: return savedPosts
            }
        }
    
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
    func getProfileCounts() async  {
        guard let userID else{return}
        do{
            let counts = try await profileService.fetchProfileCounts(userId: userID)
            self.profileCount = counts
        }catch{
            self.errorMessage = error.localizedDescription
        }
    }
    func selectTab(_ tab: ProfileTab) {
           guard selectedTab != tab else { return }
           selectedTab = tab

           // lazy load the first page for that tab
           switch tab {
           case .posts:
               if posts.isEmpty {
                   Task{
                       await loadInitialPosts()
                   }
                 
                   
               }
           case .liked:
               if likedPosts.isEmpty {
               Task{
                   await loadInitialLikedPosts()
               }
             
                   
               }
           case .saved:
        if savedPosts.isEmpty {
            Task{
            await loadInitialSavedPosts()
        }
         
        }
           }
       }
    func loadMoreIfNeeded() {
            switch selectedTab {
            case .posts:
                Task{
                  await  loadMorePosts()
                }
            case .liked:
              
                Task{
                  await  loadMoreLikedPosts()
                }
            case .saved:
                Task{
                  await  loadMoreSavedPosts()
                }
            }
        }

    
    func start() async{
         await loadProfile()
         await loadInitialPosts()
       await getProfileCounts()
         
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
            self.posts = page.posts
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
            appendDedup(page.posts, to: &posts)
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
    func loadInitialLikedPosts() async{
        guard !isLoadingLikedPosts else{return}
        isLoadingLikedPosts = true
        defer{isLoadingLikedPosts = false}
        
        do{
            let page:FeedResponse = try await postQueryService.fetchLikedPosts(limit: pageSize)
            likedPosts = page.posts
            likedPostsCursor = page.nextCursor
        }catch{
            errorMessage = "Failed to load liked posts \(error.localizedDescription)"
        }
    }
    
    func loadMoreLikedPosts()async{
        guard !isLoadingLikedPosts,let cursor = likedPostsCursor else{return}
        isLoadingLikedPosts = true
        defer{isLoadingLikedPosts = false}
        
        do{
            let page:FeedResponse = try await postQueryService.fetchLikedPosts(limit: pageSize,beforeCreatedAt: cursor.createdAt,beforeId:  cursor.postId)
            appendDedup(page.posts, to: &likedPosts)
            likedPostsCursor = page.nextCursor
        }catch{
            errorMessage = "Failed to load more liked posts \(error.localizedDescription)"
        }
    }
    
    
    func toggleFollow() {
        guard let targetUserID = userID else{return}
           guard !tryingToFollow else { return }
          
        self.isFollowing.toggle()
        
           Task { [weak self] in
               guard let self else { return }
               self.tryingToFollow = true
               defer { self.tryingToFollow = false }   // 🔹 always unlock at the end

               do {
                   let resp:FollowResponse = try await self.followService.toggleFollow(userId: targetUserID)
                   print(resp)
                  
                   if resp.is_following == self.isFollowing {
                       self.profile?.follower_count = resp.target_follower_count
                   }else{
                       // it failed
                       self.isFollowing.toggle()
                   }
               } catch {
                   self.isFollowing.toggle()
                   print(error)
                   self.errorMessage = "Follow failed, please try again."
               }
           }
       }
   
    
    
    private func appendDedup(_ new: [Post], to array: inout [Post]) {
        let existing = Set(array.map(\.id))
        let filtered = new.filter { !existing.contains($0.id) }
        array.append(contentsOf: filtered)
    }
}
//extension ProfileViewModel{
//    func loadMockData() ->[Post]{
//           var items: [Post] = []
//   
//           let authors: [UserSummary] = [
//               UserSummary(id: UUID(),
//                           username: "hakim_cyber",
//                           fullName: "Hakim Aliyev",
//                           avatarURL: URL(string: "https://picsum.photos/60"),
//                           isVerified: true),
//               UserSummary(id: UUID(),
//                           username: "zarina",
//                           fullName: "Zarina Aliyeva",
//                           avatarURL: URL(string: "https://picsum.photos/61"),
//                           isVerified: true),
//               UserSummary(id: UUID(),
//                           username: "swift_dev",
//                           fullName: "Swift Developer",
//                           avatarURL: URL(string: "https://picsum.photos/62"),
//                           isVerified: false),
//           ]
//   
//           // Generate 20 mock posts
//           for i in 0..<20 {
//               let author = authors[i % authors.count]
//   
//               let post = Post(
//                   id: UUID(),
//                   caption: "Mock caption #\(i). Designing UI without backend.",
//                   imageURL: URL(string: "https://i.pinimg.com/736x/c4/e8/d0/c4e8d07cfa77ecce2ad5c84041d8643f.jpg")!  ,
//                   location: i % 3 == 0 ? "Istanbul" : nil,
//                   likeCount: Int.random(in: 30...999),
//                   commentCount: Int.random(in: 0...100),
//                   createdAt: Date().addingTimeInterval(-Double(i * 300)), // spaced by 5min
//                   author: author,
//                   isLiked: false,
//                   isSaved: false
//               )
//   
//               items.append(post)
//           }
//   
//           return items
//       }
//}
