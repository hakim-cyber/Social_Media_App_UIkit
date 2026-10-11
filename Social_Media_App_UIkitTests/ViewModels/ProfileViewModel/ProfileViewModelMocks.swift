//
//  ProfileViewModelMocks.swift
//  Social_Media_App_UIkitTests
//
//  Created by Codex on 4/26/26.
//

import Combine
import UIKit
import Supabase
@testable import Social_Media_App_UIkit


final class ProfileViewModelMockSessionStore: SessionStoreProtocol {
    var currentUser: User?
    var isLoggedIn: Bool = false

    var isLoggedInPublisher: AnyPublisher<Bool, Never> {
        subject.eraseToAnyPublisher()
    }

    private let subject = CurrentValueSubject<Bool, Never>(false)

    func setSession(user: User, accessToken: String, refreshToken: String) {
        currentUser = user
        isLoggedIn = true
        subject.send(true)
    }

    func clearSession() {
        currentUser = nil
        isLoggedIn = false
        subject.send(false)
    }
}

final class ProfileViewModelMockProfileService: ProfileServicing {
    var fetchUserProfileResult: Result<UserProfile, Error> = .success(.mock)
    var fetchProfileCountsResult: Result<ProfileCounts, Error> = .success(.init(liked: 0, saved: 0))

    private(set) var fetchUserProfileCallCount = 0
    private(set) var fetchProfileCountsCallCount = 0

    func checkIfUserHasProfile() async throws -> Bool {
        true
    }

    func fetchUserProfile(id: UUID) async throws -> UserProfile {
        fetchUserProfileCallCount += 1
        return try fetchUserProfileResult.get()
    }

    func fetchProfileCounts(userId: UUID) async throws -> ProfileCounts {
        fetchProfileCountsCallCount += 1
        return try fetchProfileCountsResult.get()
    }

    func createNewProfile(
        username: String,
        fullName: String,
        bio: String?,
        avatarImage: UIImage?
    ) async throws -> UserProfile {
        throw ProfileViewModelTestError("Not used in tests")
    }

    func updateProfile(
        username: String,
        fullName: String,
        bio: String?,
        avatarImage: UIImage?
    ) async throws -> UserProfile {
        throw ProfileViewModelTestError("Not used in tests")
    }
}

final class ProfileViewModelMockFollowService: FollowServicing {
    var isFollowingResult: Result<Bool, Error> = .success(false)
    var toggleFollowResult: Result<FollowResponse, Error> = .success(
        .init(
            action: "followed",
            is_following: true,
            target_user_id: UUID(),
            user_id: UUID(),
            target_follower_count: 1,
            my_following_count: 1
        )
    )

    private(set) var isFollowingCallCount = 0
    private(set) var toggleFollowCallCount = 0

    func isFollowing(userId: UUID) async throws -> Bool {
        isFollowingCallCount += 1
        return try isFollowingResult.get()
    }

    func toggleFollow(userId: UUID) async throws -> FollowResponse {
        toggleFollowCallCount += 1
        return try toggleFollowResult.get()
    }

    func getFollowers(
        userID: UUID,
        limit: Int,
        beforeCursor: FollowerListCursor?
    ) async throws -> FollowerListResponse {
        throw ProfileViewModelTestError("Not used in tests")
    }

    func getFollowings(
        userID: UUID,
        limit: Int,
        beforeCursor: FollowerListCursor?
    ) async throws -> FollowerListResponse {
        throw ProfileViewModelTestError("Not used in tests")
    }

    func deleteFollower(targetUserID: UUID) async throws -> RemoveFollowResponse {
        throw ProfileViewModelTestError("Not used in tests")
    }
}

final class ProfileViewModelMockPostQueryService: PostQueryServicing {
    var fetchPostsForUserResults: [Result<FeedResponse, Error>] = []
    var fetchSavedPostsResults: [Result<FeedResponse, Error>] = []
    var fetchLikedPostsResults: [Result<FeedResponse, Error>] = []

    private(set) var fetchPostsForUserCalls: [(userID: UUID, limit: Int, beforeCreatedAt: Date?, beforeId: UUID?)] = []
    private(set) var fetchSavedPostsCalls: [(limit: Int, beforeCreatedAt: Date?, beforeId: UUID?)] = []
    private(set) var fetchLikedPostsCalls: [(userID: UUID, limit: Int, beforeCreatedAt: Date?, beforeId: UUID?)] = []

    func fetchPostsForUser(
        userID: UUID,
        limit: Int,
        beforeCreatedAt: Date?,
        beforeId: UUID?
    ) async throws -> FeedResponse {
        fetchPostsForUserCalls.append((userID, limit, beforeCreatedAt, beforeId))
        return try fetchPostsForUserResults.removeFirst().get()
    }

    func fetchSavedPosts(
        limit: Int,
        beforeCreatedAt: Date?,
        beforeId: UUID?
    ) async throws -> FeedResponse {
        fetchSavedPostsCalls.append((limit, beforeCreatedAt, beforeId))
        return try fetchSavedPostsResults.removeFirst().get()
    }

    func fetchLikedPosts(
        userID: UUID,
        limit: Int,
        beforeCreatedAt: Date?,
        beforeId: UUID?
    ) async throws -> FeedResponse {
        fetchLikedPostsCalls.append((userID, limit, beforeCreatedAt, beforeId))
        return try fetchLikedPostsResults.removeFirst().get()
    }
}

final class ProfileViewModelMockPostActionService: PostActionServicing {
    var createPostResult: Result<Post, Error> = .success(.mockPost)
    var deleteResult: Result<PostDeleteResponse, Error> = .success(
        .init(deleted: true, post_id: UUID(), new_post_count: 0)
    )
    var likeResult: Result<LikeResponse, Error> = .success(
        .init(action: "liked", is_liked: true, like_count: 1, post_id: UUID(), user_id: UUID())
    )
    var saveResult: Result<SavePostResponse, Error> = .success(
        .init(action: "saved", is_saved: true, post_id: UUID(), user_id: UUID())
    )

    func createPost(caption: String?, image: UIImage, location: String?) async throws -> Post {
        try createPostResult.get()
    }

    func deletePost(postId: UUID) async throws -> PostDeleteResponse {
        try deleteResult.get()
    }

    func addLikeToPost(postId: UUID) async throws -> LikeResponse {
        try likeResult.get()
    }

    func savePost(postId: UUID) async throws -> SavePostResponse {
        try saveResult.get()
    }
}

final class ProfileViewModelMockTranslationController: PostTranslationControlling {
    var onError: ((String) -> Void)?

    var translationsPublisher: AnyPublisher<[UUID: TranslationState], Never> {
        subject.eraseToAnyPublisher()
    }

    private let subject = CurrentValueSubject<[UUID: TranslationState], Never>([:])

    func toggle(postId: UUID, text: String) {}
}

struct ProfileViewModelMockSessionManager: SessionManaging {
    func logout() async throws {}
}

struct ProfileViewModelTestError: LocalizedError {
    let message: String

    init(_ message: String) {
        self.message = message
    }

    var errorDescription: String? {
        message
    }
}
