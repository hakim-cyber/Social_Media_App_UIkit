//
//  FeedViewModel.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 10/22/25.
//

import Foundation
import Combine


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

    
    
    init(service: FeedService, realtime: FeedRealtime) {
            self.service = service
            self.realtime = realtime
        }
    private(set) var cancellables = Set<AnyCancellable>()
    private let pageSize = 20
    private let newerPageSize = 30
    
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
                        Task { @MainActor in await self?.handleInsertRaw(raw) }
                       
                    },
                    onUpdate: { [weak self] raw in
                      
                        Task { @MainActor in  await self?.handleUpdateRaw(raw) }
                    },
                    onDelete: { [weak self] id in
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
                       author: post.author
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
            isRefreshing = false
            bufferedNewCount = 0
        }catch{
            
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
