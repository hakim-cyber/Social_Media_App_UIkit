//
//  Mocks.swift
//  Social_Media_App_UIkitTests
//
//  Created by aplle on 4/25/26.
//

import SwiftUI
import Combine
@testable import Social_Media_App_UIkit

final class MockFeedService: FeedServicing {
    var responses: [Result<FeedResponse, Error>] = []
    var calls: [(limit: Int, beforeCreatedAt: Date?, beforeId: UUID?)] = []

    func loadGlobalFeed(limit: Int, beforeCreatedAt: Date?, beforeId: UUID?) async throws -> FeedResponse {
        calls.append((limit, beforeCreatedAt, beforeId))
        return try responses.removeFirst().get()
    }
}


final class MockFeedRealtimeService: FeedRealtimeServicing {
    var handlers: FeedRealtime.Handlers?

    func subscribe(handlers: FeedRealtime.Handlers) async throws {
        self.handlers = handlers
    }

    func unsubscribe() async {}
}

final class MockTranslationController: PostTranslationControlling {
    var onError: ((String) -> Void)?
    private let subject = CurrentValueSubject<[UUID: TranslationState], Never>([:])

    var translationsPublisher: AnyPublisher<[UUID: TranslationState], Never> {
        subject.eraseToAnyPublisher()
    }

    func toggle(postId: UUID, text: String) {}
}


final class MockUserService: UserServicing {
    var result: Result<UserSummary, Error> = .success(.mock(id: UUID()))

    func fetchUserSummary(id: UUID) async throws -> UserSummary {
        try result.get()
    }
}

final class MockPostActionService: PostActionServicing {
    var likeResult: Result<LikeResponse, Error> = .success(
        LikeResponse(action: "liked", is_liked: true, like_count: 1, post_id: UUID(), user_id: UUID())
    )
    var saveResult: Result<SavePostResponse, Error> = .success(
        SavePostResponse(action: "saved", is_saved: true, post_id: UUID(), user_id: UUID())
    )
    var deleteResult: Result<PostDeleteResponse, Error> = .success(
        PostDeleteResponse(deleted: true, post_id: UUID(), new_post_count: 0)
    )

    func createPost(caption: String?, image: UIImage, location: String?) async throws -> Post {
        fatalError("Not needed in FeedViewModel tests")
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


struct TestError: LocalizedError {
    let message: String

    init(_ message: String) { self.message = message }

    var errorDescription: String? { message }
}
