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
    @Published private(set) var isLoadingMore = false
    @Published private(set) var isRefreshing = false
    @Published private(set) var errorMessage: String? = nil
    
    
    private let postId:UUID
    private let service: CommentService
    private var nextCursor:CommentCursor?
    private let pageSize = 20
    
    init(postId:UUID,service:CommentService){
        self.postId = postId
        self.service = service
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
