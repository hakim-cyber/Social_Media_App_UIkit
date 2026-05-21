//
//  FeedViewModelIntegrationTests.swift
//  Social_Media_App_UIkitTests
//
//  Created by aplle on 5/21/26.
//

import Testing

import Supabase
@testable import Social_Media_App_UIkit
import Foundation

@MainActor
struct FeedViewModelIntegrationTests {

    
    @Test func testLoadInitialUsingRealFeedServiceSetsPosts() async throws {
        URLProtocol.registerClass(MockURLProtocol.self)
        
        MockURLProtocol.handler = { request in
            #expect(request.url?.path == "/rest/v1/rpc/get_global_feed_cursor")
            

            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            )!

            let data = try TestFixture.data(
                named: "global_feed_success",
                subdirectory: "Feed"
            )

            return (response, data)
        }

        let client = SupabaseClient(
            supabaseURL: URL(string: "https://test-project.supabase.co")!,
            supabaseKey: "test-anon-key"
        )
        
        let feedService =  FeedService(client: client)
        
        let feedVM =  FeedViewModel(service: feedService, realtime: MockFeedRealtimeService(), translationController: MockTranslationController(), userService: MockUserService(), postService: MockPostActionService())
        await feedVM.loadInitial()
        
        #expect(feedVM.posts.count == 8)
        #expect(feedVM.posts.first?.id.uuidString == "11111111-1111-1111-1111-111111111111")
        #expect(feedVM.isRefreshing == false)
        #expect(feedVM.errorMessage == nil)
        #expect(feedVM.bufferedNewCount == 0)
    }
    
    @Test func testLoadInitialUsingRealFeedServiceWhenServerFailsSetsErrorMessage() async throws {
        URLProtocol.registerClass(MockURLProtocol.self)
        
        MockURLProtocol.handler = { request in
            #expect(request.url?.path == "/rest/v1/rpc/get_global_feed_cursor")
            

            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 500,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            )!

            let data = try TestFixture.data(
                named: "global_feed_server_error",
                subdirectory: "Feed"
            )

            return (response, data)
        }

        let client = SupabaseClient(
            supabaseURL: URL(string: "https://test-project.supabase.co")!,
            supabaseKey: "test-anon-key"
        )
        
        let feedService =  FeedService(client: client)
        
        let feedVM =  FeedViewModel(service: feedService, realtime: MockFeedRealtimeService(), translationController: MockTranslationController(), userService: MockUserService(), postService: MockPostActionService())
        await feedVM.loadInitial()
        
        #expect(feedVM.posts.count == 0)
       
        #expect(feedVM.isRefreshing == false)
        #expect(feedVM.errorMessage != nil)
    
      
    }
}
