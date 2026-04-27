//
//  Test.swift
//  Social_Media_App_UIkitTests
//
//  Created by aplle on 4/25/26.
//

import Testing
@testable import Social_Media_App_UIkit
import SwiftUI

@MainActor
struct FeedViewModelTests {

    @Test
    func test_loadInitial_success_setsPosts_andClearsBufferedCount() async{
        let oldPost = makePost(createdAt: .now.addingTimeInterval(-100))
        let service = MockFeedService()
        service.responses = [.success(.init(posts: [oldPost], hasMore: true, nextCursor: .init(createdAt: oldPost.createdAt, postId: oldPost.id)))]
        
        let sut = makeSUT(feedService: service)
        
        await sut.loadInitial()
        
        #expect(sut.posts.map(\.id) == [oldPost.id])
        #expect(sut.bufferedNewCount == 0)
        #expect(sut.isRefreshing == false)
        #expect(sut.errorMessage == nil)
    }

    @Test
    func test_loadMore_afterInitialLoad_usesStoredCursor_andAppendsOnlyUnseenPost() async{
        let p1 = makePost(createdAt:.now.addingTimeInterval(-100))
        let p2 = makePost(createdAt:.now.addingTimeInterval(-90))
        let cursor = FeedCursor(createdAt: p1.createdAt, postId: p1.id)
        
        let duplicateP2 = p2
        let p3 = makePost(createdAt:.now.addingTimeInterval(-80))
        
        
        let service = MockFeedService()
        service.responses = [.success(.init(posts: [p1,p2], hasMore: true, nextCursor: cursor)),.success(.init(posts: [duplicateP2,p3], hasMore: false, nextCursor: nil))]
        
        let sut = makeSUT(feedService: service)
        
       await sut.loadInitial()
       await sut.loadMore()
        
        #expect(sut.posts == [p1,p2,p3])
        #expect(service.calls.count == 2)
        #expect(service.calls[1].beforeCreatedAt == cursor.createdAt)
        #expect(service.calls[1].beforeId == cursor.postId)
        #expect(sut.isRefreshing == false)
        #expect(sut.isLoadingMore == false)
        #expect(sut.errorMessage == nil)
        
        
    }
    
    @Test
    func test_handleInsertRaw_afterInitialLoad_buffersNewerPost() async{
        let oldPost = makePost(createdAt: .now.addingTimeInterval(-100))
      
        let newAuthorID = UUID()
        
      
        let service = MockFeedService()
        service.responses = [.success(.init(posts: [oldPost], hasMore: true, nextCursor: .init(createdAt: oldPost.createdAt, postId: oldPost.id)))]
        let userService = MockUserService()
        userService.result = .success(.mock(id: newAuthorID))
        let sut = makeSUT(feedService: service,userService: userService)
        
        await sut.loadInitial()
        
        let raw = RawPost(id: UUID(), caption: "kdkdfk", image_url:  URL(string: "https://example.com/new.jpg")! , location: nil, like_count: 4, comment_count: 3, created_at:  .now.addingTimeInterval(-80), author_id: newAuthorID)
        await sut.handleInsertRaw(raw)
 
        #expect(sut.posts.count == 1)
        #expect(sut.bufferedNewCount == 1)
        
    }
    
    @Test
    func test_toggleLike_failure_rollsBackOptimisticState_andSetsErrorMessage() async {
        let post = makePost(likeCount: 3, isLiked: false)
        let service = MockFeedService()
        service.responses = [.success(.init(posts: [post], hasMore: false, nextCursor: nil))]

        
        let postService = MockPostActionService()
        postService.likeResult = .failure(TestError("network failed"))
        let sut = makeSUT(feedService: service,postService: postService)
        
      
       await sut.loadInitial()
        sut.toggleLike(for: post.id, desiredState: true)
      
        await assertEventually {
            sut.posts.first?.isLiked == false &&
            sut.posts.first?.likeCount == 3 &&
            sut.errorMessage == "Like failed, please try again."
        }
        
    }
    @Test
    func test_toggleLike_success_appliesBackendResponse() async {
        let post = makePost(likeCount: 0, isLiked: false)
        let service = MockFeedService()
        service.responses = [.success(.init(posts: [post], hasMore: false, nextCursor: nil))]

        
        let postService = MockPostActionService()
        postService.likeResult = .success(LikeResponse(action: "like", is_liked: true, like_count: 1, post_id: post.id, user_id:UUID()))
        let sut = makeSUT(feedService: service,postService: postService)
        
      
       await sut.loadInitial()
        sut.toggleLike(for: post.id, desiredState: true)
      
        await assertEventually {
            sut.posts.first?.isLiked == true &&
            sut.posts.first?.likeCount == 1 &&
            sut.errorMessage == nil
        }
        
    }
    
    @Test
    func test_deletePost_success_removesPostFromFeed() async {
        let oldPost = makePost(createdAt: .now.addingTimeInterval(-100))
        let service = MockFeedService()
        service.responses = [.success(.init(posts: [oldPost], hasMore: true, nextCursor: .init(createdAt: oldPost.createdAt, postId: oldPost.id)))]
        
        
        let postService = MockPostActionService()
        postService.deleteResult = .success(.init(deleted: true, post_id: oldPost.id, new_post_count: 0))
        
        
        let sut = makeSUT(feedService: service,postService: postService)
        
        await sut.loadInitial()
        
       await sut.deletePost(post: oldPost.id)
        
        #expect( sut.posts.isEmpty)
       
    }
    
    @Test
    func test_revealBufferedNew_prependsBufferedPostsInNewestFirstOrder() async{
        let oldPost = makePost(createdAt: .now.addingTimeInterval(-100))
      
        let newAuthorID = UUID()
        
      
        let service = MockFeedService()
        service.responses = [.success(.init(posts: [oldPost], hasMore: true, nextCursor: .init(createdAt: oldPost.createdAt, postId: oldPost.id)))]
        let userService = MockUserService()
        userService.result = .success(.mock(id: newAuthorID))
        let sut = makeSUT(feedService: service,userService: userService)
        
        await sut.loadInitial()
        let raw2ID = UUID()
        
        let raw1 = RawPost(id:UUID(), caption: "first", image_url:  URL(string: "https://example.com/new.jpg")! , location: nil, like_count: 4, comment_count: 3, created_at:  .now.addingTimeInterval(-80), author_id: newAuthorID)
        let raw2 = RawPost(id: raw2ID, caption: "second", image_url:  URL(string: "https://example.com/new.jpg")! , location: nil, like_count: 4, comment_count: 3, created_at:  .now.addingTimeInterval(-70), author_id: newAuthorID)
        await sut.handleInsertRaw(raw1)
        await sut.handleInsertRaw(raw2)
 
        #expect(sut.posts.count == 1)
        #expect(sut.bufferedNewCount == 2)
        
        sut.revealBufferedNew()
        
        #expect(sut.posts.count == 3)
        #expect(sut.bufferedNewCount == 0)
        #expect(sut.posts.first?.id == raw2.id)
        
    }
}


