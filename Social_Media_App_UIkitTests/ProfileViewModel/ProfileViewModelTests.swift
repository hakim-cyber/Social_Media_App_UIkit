//
//  ProfileViewModelTests.swift
//  Social_Media_App_UIkitTests
//
//  Created by Codex on 4/26/26.
//
import Foundation
import Testing
@testable import Social_Media_App_UIkit

@MainActor
struct ProfileViewModelTests {

    @Test
    func test_loadIfNeeded_firstCall_loadsProfilePostsCountsAndFollowState() async {
        let userID = UUID()
        let profile = makeProfile(id: userID, followerCount: 12)
        let post = makePost()
        let counts = ProfileCounts(liked: 7, saved: 3)

        let profileService = ProfileViewModelMockProfileService()
        profileService.fetchUserProfileResult = .success(profile)
        profileService.fetchProfileCountsResult = .success(counts)

        let followService = ProfileViewModelMockFollowService()
        followService.isFollowingResult = .success(true)

        let postQueryService = ProfileViewModelMockPostQueryService()
        postQueryService.fetchPostsForUserResults = [
            .success(makeFeedResponse(posts: [post]))
        ]

        let sut = makeSUT(
            target: .user(id: userID),
            profileService: profileService,
            followService: followService,
            postQueryService: postQueryService
        )

        await sut.loadIfNeeded()

        #expect(sut.profile == profile)
        #expect(sut.isFollowing == true)
        #expect(sut.posts == [post])
        #expect(sut.profileCount == counts)
        #expect(profileService.fetchUserProfileCallCount == 1)
        #expect(profileService.fetchProfileCountsCallCount == 1)
        #expect(followService.isFollowingCallCount == 1)
        #expect(postQueryService.fetchPostsForUserCalls.count == 1)
    }

    @Test
    func test_loadIfNeeded_secondCall_doesNotReloadAgain() async {
        let userID = UUID()
        let profileService = ProfileViewModelMockProfileService()
        profileService.fetchUserProfileResult = .success(makeProfile(id: userID))
        profileService.fetchProfileCountsResult = .success(ProfileCounts(liked: 2, saved: 1))

        let followService = ProfileViewModelMockFollowService()
        followService.isFollowingResult = .success(false)

        let postQueryService = ProfileViewModelMockPostQueryService()
        postQueryService.fetchPostsForUserResults = [
            .success(makeFeedResponse(posts: [makePost()]))
        ]

        let sut = makeSUT(
            target: .user(id: userID),
            profileService: profileService,
            followService: followService,
            postQueryService: postQueryService
        )

        await sut.loadIfNeeded()
        await sut.loadIfNeeded()

        #expect(profileService.fetchUserProfileCallCount == 1)
        #expect(profileService.fetchProfileCountsCallCount == 1)
        #expect(followService.isFollowingCallCount == 1)
        #expect(postQueryService.fetchPostsForUserCalls.count == 1)
    }

    @Test
    func test_selectTab_liked_whenEmpty_loadsInitialLikedPosts() async {
        let userID = UUID()
        let likedPost = makePost()

        let postQueryService = ProfileViewModelMockPostQueryService()
        postQueryService.fetchLikedPostsResults = [
            .success(makeFeedResponse(posts: [likedPost]))
        ]

        let sut = makeSUT(
            target: .user(id: userID),
            postQueryService: postQueryService
        )

        sut.selectTab(.liked)

        await assertEventually {
            sut.selectedTab == .liked &&
            sut.likedPosts == [likedPost] &&
            postQueryService.fetchLikedPostsCalls.count == 1
        }
    }

    @Test
    func test_toggleFollow_failure_rollsBackStateAndSetsErrorMessage() async {
        let userID = UUID()
        let profileService = ProfileViewModelMockProfileService()
        profileService.fetchUserProfileResult = .success(makeProfile(id: userID, followerCount: 10))

        let followService = ProfileViewModelMockFollowService()
        followService.isFollowingResult = .success(false)
        followService.toggleFollowResult = .failure(ProfileViewModelTestError("network failed"))

        let sut = makeSUT(
            target: .user(id: userID),
            profileService: profileService,
            followService: followService
        )

        await sut.loadProfile()
        sut.toggleFollow()

        await assertEventually {
            sut.isFollowing == false &&
            sut.errorMessage == "Follow failed, please try again."
        }
    }

    @Test
    func test_toggleLike_failure_rollsBackPostAcrossPostsAndLikedPosts_andSetsErrorMessage() async {
        let userID = UUID()
        let sharedID = UUID()
        let sharedPost = makePost(id: sharedID, likeCount: 4, isLiked: false)

        let postQueryService = ProfileViewModelMockPostQueryService()
        postQueryService.fetchPostsForUserResults = [
            .success(makeFeedResponse(posts: [sharedPost]))
        ]
        postQueryService.fetchLikedPostsResults = [
            .success(makeFeedResponse(posts: [sharedPost]))
        ]

        let postService = ProfileViewModelMockPostActionService()
        postService.likeResult = .failure(ProfileViewModelTestError("like failed"))

        let sut = makeSUT(
            target: .user(id: userID),
            postQueryService: postQueryService,
            postService: postService
        )

        await sut.loadInitialPosts()
        await sut.loadInitialLikedPosts()
        sut.toggleLike(for: sharedID, desiredState: true)

        await assertEventually {
            sut.posts.first?.isLiked == false &&
            sut.posts.first?.likeCount == 4 &&
            sut.likedPosts.first?.isLiked == false &&
            sut.likedPosts.first?.likeCount == 4 &&
            sut.errorMessage == "Like failed"
        }
    }

    @Test
    func test_toggleSave_failure_rollsBackSavedStateAndSetsErrorMessage() async {
        let userID = UUID()
        let post = makePost(isSaved: false)

        let postQueryService = ProfileViewModelMockPostQueryService()
        postQueryService.fetchPostsForUserResults = [
            .success(makeFeedResponse(posts: [post]))
        ]

        let postService = ProfileViewModelMockPostActionService()
        postService.saveResult = .failure(ProfileViewModelTestError("save failed"))

        let sut = makeSUT(
            target: .user(id: userID),
            postQueryService: postQueryService,
            postService: postService
        )

        await sut.loadInitialPosts()
        sut.toggleSave(for: post.id, desiredState: true)

        await assertEventually {
            sut.posts.first?.isSaved == false &&
            sut.errorMessage == "Save failed"
        }
    }

    @Test
    func test_deletePost_success_removesPostFromPostsAndLikedPosts() async {
        let userID = UUID()
        let sharedID = UUID()
        let sharedPost = makePost(id: sharedID)

        let postQueryService = ProfileViewModelMockPostQueryService()
        postQueryService.fetchPostsForUserResults = [
            .success(makeFeedResponse(posts: [sharedPost]))
        ]
        postQueryService.fetchLikedPostsResults = [
            .success(makeFeedResponse(posts: [sharedPost]))
        ]

        let postService = ProfileViewModelMockPostActionService()
        postService.deleteResult = .success(
            PostDeleteResponse(deleted: true, post_id: sharedID, new_post_count: 0)
        )

        let sut = makeSUT(
            target: .user(id: userID),
            postQueryService: postQueryService,
            postService: postService
        )

        await sut.loadInitialPosts()
        await sut.loadInitialLikedPosts()
        sut.deletePost(post: sharedID)

        await assertEventually {
            sut.posts.isEmpty &&
            sut.likedPosts.isEmpty
        }
    }
}
