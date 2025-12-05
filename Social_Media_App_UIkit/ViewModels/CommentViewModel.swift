//
//  CommentViewModel.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 12/4/25.
//


import Foundation
import Combine




@MainActor
class CommentViewModel{
    @Published private(set) var comments: [PostComment] = []
    @Published private(set) var commmentsCount = 0
    @Published private(set) var isLoadingMore = false
    @Published private(set) var isRefreshing = false
    @Published private(set) var errorMessage: String? = nil
    
    
    private let postId:UUID
    private let service: CommentService
    private var nextCursor:CommentCursor?
    private let pageSize = 20
    
    init(postId:UUID,service:CommentService,commentsCount:Int){
        self.postId = postId
        self.service = service
        self.commmentsCount = commentsCount
    }
    
    
    func loadInitial() async{
        guard !isRefreshing else{return}
        isRefreshing = true
        defer{isRefreshing = false}
        
        do{
            let page:CommentPageResponse = try await service.fetchComments(postId: postId,limit: pageSize)
            comments = page.comments
            nextCursor = page.nextCursor
        }catch{
            errorMessage = "Failed to load comments \(error.localizedDescription)"
        }
    }
    
    func loadMore()async{
        guard !isLoadingMore,let cursor = nextCursor else{return}
        isLoadingMore = true
        defer{isLoadingMore = false}
        
        do{
            let page:CommentPageResponse = try await service.fetchComments(postId: postId,limit: pageSize,beforeCursor: cursor)
            comments.append(contentsOf: page.comments)
            nextCursor = page.nextCursor
        }catch{
            errorMessage = "Failed to load more comments \(error.localizedDescription)"
        }
    }
    
}
#if DEBUG
extension CommentViewModel {
    /// Populates mock comments for UI testing / previews.
    func loadMockData() {
        comments = [
            PostComment(
                id: UUID(),
                text: "This is such a cool post! 🔥",
                created_at: .now,
                post_id: postId,
                author: UserSummary(
                    id: UUID(),
                    username: "mock_anna",
                    fullName: "Anna Green",
                    avatarURL: nil,
                    isVerified: true
                )
            ),
            PostComment(
                id: UUID(),
                text: "Instagram-style sheet works perfectly!",
                created_at: .now.addingTimeInterval(-200),
                post_id: postId,
                author: UserSummary(
                    id: UUID(),
                    username: "mock_john",
                    fullName: "John Doe",
                    avatarURL: nil,
                    isVerified: false
                )
            ),
            PostComment(
                id: UUID(),
                text: "Testing multiline comment layout to check cell resizing.",
                created_at: .now.addingTimeInterval(-500),
                post_id: postId,
                author: UserSummary(
                    id: UUID(),
                    username: "mock_sue",
                    fullName: "Sue Park",
                    avatarURL: nil,
                    isVerified: false
                )
            ),PostComment(
                id: UUID(),
                text: "This is such a cool post! 🔥,This is such a cool post! 🔥,This is such a cool post! 🔥,This is such a cool post! 🔥,This is such a cool post! 🔥,This is such a cool post! 🔥,,This is such a cool post! 🔥",
                created_at: .now,
                post_id: postId,
                author: UserSummary(
                    id: UUID(),
                    username: "mock_anna",
                    fullName: "Anna Green",
                    avatarURL: nil,
                    isVerified: true
                )
            ),
            PostComment(
                id: UUID(),
                text: "Instagram-style sheet works perfectlyThis is such a cool post! 🔥This is such a cool post! 🔥This is such a cool post! 🔥This is such a cool post! 🔥!",
                created_at: .now.addingTimeInterval(-200),
                post_id: postId,
                author: UserSummary(
                    id: UUID(),
                    username: "mock_john",
                    fullName: "John Doe",
                    avatarURL: nil,
                    isVerified: false
                )
            ),
        ]
        
        commmentsCount = comments.count
        nextCursor = nil
        errorMessage = nil
    }
}
#endif
