//
//  Extension+ProfileViewModelTests.swift
//  Social_Media_App_UIkitTests
//
//  Created by Codex on 4/26/26.
//

import Foundation
import Testing
@testable import Social_Media_App_UIkit

extension ProfileViewModelTests {
    @MainActor
    func makeSUT(
        target: ProfileTarget,
        sessionStore: ProfileViewModelMockSessionStore? = nil,
        profileService: ProfileViewModelMockProfileService? = nil,
        followService: ProfileViewModelMockFollowService? = nil,
        postQueryService: ProfileViewModelMockPostQueryService? = nil,
        postService: ProfileViewModelMockPostActionService? = nil,
        translationController: ProfileViewModelMockTranslationController? = nil,
        sessionManager: ProfileViewModelMockSessionManager? = nil
    ) -> ProfileViewModel {
        let sessionStore = sessionStore ?? ProfileViewModelMockSessionStore()
        let profileService = profileService ?? ProfileViewModelMockProfileService()
        let followService = followService ?? ProfileViewModelMockFollowService()
        let postQueryService = postQueryService ?? ProfileViewModelMockPostQueryService()
        let postService = postService ?? ProfileViewModelMockPostActionService()
        let translationController = translationController ?? ProfileViewModelMockTranslationController()
        let sessionManager = sessionManager ?? ProfileViewModelMockSessionManager()

        return ProfileViewModel(
            target: target,
            sessionStore: sessionStore,
            profileService: profileService,
            followService: followService,
            postQueryService: postQueryService,
            postService: postService,
            translationController: translationController,
            sessionManager: sessionManager
        )
    }

    func makeProfile(
        id: UUID = UUID(),
        followerCount: Int? = 0,
        followingCount: Int? = 0,
        postCount: Int? = 0
    ) -> UserProfile {
        UserProfile(
            id: id,
            email: "user@test.com",
            username: "user_\(id.uuidString.prefix(6))",
            full_name: "Test User",
            bio: "bio",
            avatar_url: nil,
            follower_count: followerCount,
            following_count: followingCount,
            post_count: postCount,
            is_verified: false,
            created_at: .now
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

    func makeFeedResponse(
        posts: [Post],
        hasMore: Bool = false,
        nextCursor: FeedCursor? = nil
    ) -> FeedResponse {
        FeedResponse(posts: posts, hasMore: hasMore, nextCursor: nextCursor)
    }

    func assertEventually(
        timeout: TimeInterval = 1.0,
        interval: TimeInterval = 0.02,
        _ condition: @escaping () -> Bool
    ) async {
        let deadline = Date().addingTimeInterval(timeout)

        while Date() < deadline {
            if condition() {
                #expect(true)
                return
            }

            try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
        }

        #expect(Bool(false))
    }
}
