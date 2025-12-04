//
//  FeedViewModel.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 10/22/25.
//

import Foundation
import Combine

@MainActor
class FeedViewModel{
    // MARK: - Published to VC
       @Published private(set) var posts: [Post] = []
       @Published private(set) var isRefreshing = false
       @Published private(set) var isLoadingMore = false
       @Published private(set) var bufferedNewCount = 0
       @Published private(set) var errorMessage: String? = nil
    
    
    private let service: FeedService
    private let realtime: FeedRealtime
    private var state = FeedState()
    private let userService = UserService()
    private let authorCache = AuthorCache()
    private let postService = PostService()

    
    
    init(service: FeedService, realtime: FeedRealtime) {
            self.service = service
            self.realtime = realtime
        }
    private(set) var cancellables = Set<AnyCancellable>()
    private let pageSize =  20
    private let newerPageSize = 40
    
    private var likingPosts = Set<UUID>()
    private var savingPosts = Set<UUID>()
    
    // Call from VC.viewDidLoad in a Task
        func start() async {
            await loadInitial()
            await startRealtime()
        }
    // MARK: - Realtime
        func startRealtime() async {
            do {
                try await realtime.subscribe(handlers: .init(
                    onInsert: { [weak self] raw in
                        print("Realtime insert \(raw)")
                        Task { @MainActor in await self?.handleInsertRaw(raw) }
                       
                    },
                    onUpdate: { [weak self] raw in
                        print("Realtime update \(raw)")
                        Task { @MainActor in  await self?.handleUpdateRaw(raw) }
                    },
                    onDelete: { [weak self] id in
                        print("Realtime delete \(id)")
                        Task { @MainActor in self?.handleDelete(id) }
                    }
                ))
            } catch {
                errorMessage = "Realtime subscribe failed: \(error.localizedDescription)"
            }
        }
    func handleInsertRaw(_ raw: RawPost) async {
            // 1) author via cache (inflight dedup + TTL)
            let author: UserSummary? = try? await authorCache.getOrFetch(raw.author_id) { [weak self] id in
                guard let self = self else { throw CancellationError() }
                return try await self.userService.fetchUserSummary(id: id)
            }
      
            // 2) Build full Post (flags are false on insert by default)
            let full = Post(
                id: raw.id,
                caption: raw.caption,
                imageURL: raw.image_url,
                location: raw.location,
                likeCount: raw.like_count,
                commentCount: raw.comment_count,
                createdAt: raw.created_at,
                author: author  ?? UserSummary(id:raw.author_id, username: "Unknown", fullName: "Someone", avatarURL: nil, isVerified: false) ,
                isLiked: false,
                isSaved: false
            )

            // 3) Dedupe + buffer/insert using topCursor
            if let top = state.topCursor {
                let newer = (full.createdAt > top.createdAt) ||
                            (full.createdAt == top.createdAt && full.id.uuidString > top.postId.uuidString)
                guard newer && !state.seen.contains(full.id) else { return }
                state.bufferedNew.append(full)
                bufferedNewCount = state.bufferedNew.count
                print("Buffer count \(bufferedNewCount)")
            } else {
                state.posts.insert(full, at: 0)
                state.seen.insert(full.id)
                posts = state.posts
                state.topCursor = FeedCursor(createdAt: full.createdAt, postId: full.id)
            }
        }
        private func handleUpdateRaw(_ raw: RawPost) async {
            // Update existing post (if visible)
               if let index = state.posts.firstIndex(where: { $0.id == raw.id }) {
                   var post = state.posts[index]
                   post = Post(
                       id: post.id,
                       caption: raw.caption,
                       imageURL: raw.image_url,
                       location: raw.location,
                       likeCount: raw.like_count,
                       commentCount: raw.comment_count,
                       createdAt: raw.created_at,
                       author: post.author,
                       isLiked: post.isLiked,
                       isSaved: post.isSaved,
                   )
                   state.posts[index] = post
                   posts = state.posts
               }
               //  if it’s in bufferedNew
               else if let index = state.bufferedNew.firstIndex(where: { $0.id == raw.id }) {
                   var post = state.bufferedNew[index]
                   post.caption = raw.caption
                   post.likeCount = raw.like_count
                   post.commentCount = raw.comment_count
                   state.bufferedNew[index] = post
               }
        }

       
        private func handleDelete(_ id: UUID) {
            if let i = state.posts.firstIndex(where: { $0.id == id }) {
                state.posts.remove(at: i)
                state.seen.remove(id)
                posts = state.posts
            }
            if let j = state.bufferedNew.firstIndex(where: { $0.id == id }) {
                state.bufferedNew.remove(at: j)
                bufferedNewCount = state.bufferedNew.count
            }
        }
    func loadInitial()async{
        guard !isRefreshing else{return}
        
        state.isRefreshing = true
        self.isRefreshing = true
        defer{
            isRefreshing = false
            state.isRefreshing = false
        }
        
        do{
            let response = try await service.loadGlobalFeed(limit: pageSize)
            
            state.posts = response.posts
            state.seen = Set(response.posts.map(\.id))
            state.nextCursor = response.nextCursor
            if let firstPost = response.posts.first{
                state.topCursor  = .init(createdAt: firstPost.createdAt, postId: firstPost.id)
            }
            state.bufferedNew = []
            
            
            // publishing
            posts = state.posts
           
            bufferedNewCount = 0
        }catch{
            errorMessage = "Failed to load First page: \(error.localizedDescription)"
                   
        }
    }
    
    // post fetching funcs
    func loadMore() async {
        // Use internal flag for logic
        guard !state.isLoadingMore, let nextCursor = state.nextCursor else { return }
print("Loading more...")
        state.isLoadingMore = true
        isLoadingMore = true
        defer {
            state.isLoadingMore = false
            isLoadingMore = false
        }

        do {
            let response = try await service.loadGlobalFeed(
                limit: pageSize,
                beforeCreatedAt: nextCursor.createdAt,
                beforeId: nextCursor.postId
            )
            
            // Only take posts we haven't seen yet
            let newPosts = response.posts.filter { !state.seen.contains($0.id) }
          
           
            // Append only the new ones
            state.posts.append(contentsOf: newPosts)
            newPosts.forEach { state.seen.insert($0.id) }

            state.nextCursor = response.nextCursor

            // publish
            posts = state.posts
            
        } catch {
            errorMessage = "Failed to load more: \(error.localizedDescription)"
           print("Failed to load more: \(error.localizedDescription)")
        }
    }
  
    func refresh() async {
        guard !state.isRefreshing else { return }

        state.isRefreshing = true
        isRefreshing = true
        defer {
            state.isRefreshing = false
            isRefreshing = false
        }

        do {
            let response = try await service.loadGlobalFeed(limit: pageSize)

            // Replace posts
            state.posts = response.posts
            state.seen = Set(response.posts.map(\.id))

            // 🔹 IMPORTANT: reset pagination cursor
            state.nextCursor = response.nextCursor

            // 🔹 Reset top cursor to newest post
            if let first = response.posts.first {
                state.topCursor = .init(createdAt: first.createdAt, postId: first.id)
            } else {
                state.topCursor = nil
            }

            // 🔹 Clear buffered realtime items (or choose merge strategy)
            state.bufferedNew.removeAll(keepingCapacity: true)
            bufferedNewCount = 0

            // Publish to UI
            posts = state.posts
        } catch {
            errorMessage = "Refresh failed: \(error.localizedDescription)"
            print("Refresh failed: \(error.localizedDescription)")
        }
    }
    func revealBufferedNew() {
           guard !state.bufferedNew.isEmpty else { return }
        
        
        let sorted = state.bufferedNew.sorted {post1,post2 in
            if post1.createdAt != post2.createdAt{
                return post1.createdAt > post2.createdAt
            }
            return post1.id.uuidString > post2.id.uuidString
        }
        
        state.bufferedNew.removeAll(keepingCapacity: true)
        bufferedNewCount = 0
        
        state.posts.insert(contentsOf: sorted, at: 0)
        sorted.forEach { state.seen.insert($0.id) }
        
        if let first = state.posts.first{
            self.state.topCursor = .init(createdAt: first.createdAt, postId: first.id)
        }
        
        self.posts = state.posts
       }
    
    
    // button actions
    
    func toggleLike(for postId: UUID, desiredState: Bool) {
           guard !likingPosts.contains(postId) else { return }
           likingPosts.insert(postId)

           guard let index = state.posts.firstIndex(where: { $0.id == postId }) else {
               likingPosts.remove(postId)
               return
           }

           let oldPost = state.posts[index]

           var updated = oldPost
           updated.isLiked = desiredState
           updated.likeCount = desiredState
               ? oldPost.likeCount + 1
               : max(0, oldPost.likeCount - 1)

           state.posts[index] = updated
           posts = state.posts   // publish

           Task { [weak self] in
               guard let self else { return }
               defer { self.likingPosts.remove(postId) }   // 🔹 always unlock at the end

               do {
                   let resp = try await self.postService.addLikeToPost(postId: postId)
                   print(resp)
                   if let idx = self.state.posts.firstIndex(where: { $0.id == postId }) {
                       self.state.posts[idx].isLiked = resp.is_liked
                       self.state.posts[idx].likeCount = resp.like_count
                       self.posts = self.state.posts
                   }
               } catch {
                   if let idx = self.state.posts.firstIndex(where: { $0.id == postId }) {
                       self.state.posts[idx] = oldPost
                       self.posts = self.state.posts
                   }
                   print(error)
                   self.errorMessage = "Like failed, please try again."
               }
           }
       }
    func toggleSave(for postId: UUID, desiredState: Bool) {
           guard !savingPosts.contains(postId) else { return }
        savingPosts.insert(postId)

           guard let index = state.posts.firstIndex(where: { $0.id == postId }) else {
               savingPosts.remove(postId)
               return
           }

           let oldPost = state.posts[index]

           var updated = oldPost
           updated.isSaved = desiredState
           

           state.posts[index] = updated
           posts = state.posts   // publish

           Task { [weak self] in
               guard let self else { return }
               defer { self.savingPosts.remove(postId) }   // 🔹 always unlock at the end

               do {
                   let resp = try await self.postService.savePost(postId: postId)
                   print(resp)
                   if let idx = self.state.posts.firstIndex(where: { $0.id == postId }) {
                       self.state.posts[idx].isSaved = resp.is_saved
                     
                       self.posts = self.state.posts
                   }
               } catch {
                   if let idx = self.state.posts.firstIndex(where: { $0.id == postId }) {
                       self.state.posts[idx] = oldPost
                       self.posts = self.state.posts
                   }
                   print(error)
                   self.errorMessage = "Save failed, please try again."
               }
           }
       }
}

// MARK: - UI-facing lightweight state
struct FeedState {
    var posts: [Post] = []
    var seen: Set<UUID> = []
    var nextCursor: FeedCursor? = nil      // for older pages
    var topCursor: FeedCursor? = nil       // newest known marker
    var bufferedNew: [Post] = []           // hold realtime inserts until user taps "New posts"
    var isLoadingMore = false
    var isRefreshing = false
}









// MARK: - MOCK (for UI design & testing)
//extension FeedViewModel {
//
//    /// Fill the feed with mock posts so UI can be designed without backend.
//    func loadMockData() {
//        var items: [Post] = []
//
//        let authors: [UserSummary] = [
//            UserSummary(id: UUID(),
//                        username: "hakim_cyber",
//                        fullName: "Hakim Aliyev",
//                        avatarURL: URL(string: "https://picsum.photos/60"),
//                        isVerified: true),
//            UserSummary(id: UUID(),
//                        username: "zarina",
//                        fullName: "Zarina Aliyeva",
//                        avatarURL: URL(string: "https://picsum.photos/61"),
//                        isVerified: true),
//            UserSummary(id: UUID(),
//                        username: "swift_dev",
//                        fullName: "Swift Developer",
//                        avatarURL: URL(string: "https://picsum.photos/62"),
//                        isVerified: false),
//        ]
//
//        // Generate 20 mock posts
//        for i in 0..<20 {
//            let author = authors[i % authors.count]
//
//            let post = Post(
//                id: UUID(),
//                caption: "Mock caption #\(i). Designing UI without backend.",
//                imageURL: URL(string: "https://www.gettyimages.com/photos/white-color")!  ,
//                location: i % 3 == 0 ? "Istanbul" : nil,
//                likeCount: Int.random(in: 30...999),
//                commentCount: Int.random(in: 0...100),
//                createdAt: Date().addingTimeInterval(-Double(i * 300)), // spaced by 5min
//                author: author,
//                isLiked: false,
//                isSaved: false
//            )
//
//            items.append(post)
//        }
//
//        // Update state
//        state.posts = items
//        posts = items
//
//        // Cursor info (fake)
//        if let first = items.first {
//            state.topCursor = FeedCursor(createdAt: first.createdAt, postId: first.id)
//        }
//        if let last = items.last {
//            state.nextCursor = FeedCursor(createdAt: last.createdAt, postId: last.id)
//        }
//
//        state.seen = Set(items.map { $0.id })
//    }
//}
