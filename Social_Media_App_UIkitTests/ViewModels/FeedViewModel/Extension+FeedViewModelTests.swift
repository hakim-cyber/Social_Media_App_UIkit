//
//  Extension+FeedViewModelTests.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 4/25/26.
//
@testable import Social_Media_App_UIkit
import Testing
import Foundation
extension FeedViewModelTests{
    @MainActor func makeSUT(
           feedService: MockFeedService = .init(),
           realtime: MockFeedRealtimeService = .init(),
           translationController: MockTranslationController = .init(),
           userService: MockUserService = .init(),
           postService: MockPostActionService = .init()
       ) -> FeedViewModel {
           FeedViewModel(
               service: feedService,
               realtime: realtime,
               translationController: translationController,
               userService: userService,
               authorCache: AuthorCache(ttl: 60, maxEntries: 100),
               postService: postService
           )
       }

       func makePost(
           id: UUID = UUID(),
           createdAt: Date = .now,
           likeCount: Int = 0,
           isLiked: Bool = false,
           isSaved: Bool = false
       ) -> Post {
           Post(
               id: id,
               caption: "caption",
               imageURL: URL(string: "https://example.com/image.jpg")!,
               location: nil,
               likeCount: likeCount,
               commentCount: 0,
               createdAt: createdAt,
               author: .mock(id: UUID()),
               isLiked: isLiked,
               isSaved: isSaved
           )
       }
    
    
    
    func assertEventually(

        timeout: TimeInterval = 1.0,

        interval: TimeInterval = 0.02,

        _ condition: @escaping () -> Bool

    ) async {

        let deadline = Date().addingTimeInterval(timeout)

        while Date() < deadline {

            if condition() {

                #expect(true) // passes

                return

            }

            try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))

        }

        #expect(false) // fails test

    }
}
