//
//  FeedServiceIntegrationTests.swift
//  Social_Media_App_UIkitTests
//
//  Created by aplle on 5/21/26.
//

import XCTest
import Supabase
@testable import Social_Media_App_UIkit


@MainActor
final class FeedServiceIntegrationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        URLProtocol.registerClass(MockURLProtocol.self)
    }

    override func tearDown() {
        MockURLProtocol.handler = nil
        URLProtocol.unregisterClass(MockURLProtocol.self)
        super.tearDown()
    }
    
    func testLoadGlobalFeedReturnsDecodedFeedResponse() async throws {
        MockURLProtocol.handler = { request in
            XCTAssertEqual(request.url?.path, "/rest/v1/rpc/get_global_feed_cursor")

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
        
        let sut = FeedService(client: client)

        let feed = try await sut.loadGlobalFeed(
            limit: 20,
            beforeCreatedAt: nil,
            beforeId: nil
        )

        XCTAssertEqual(feed.posts.count, 8)
        XCTAssertEqual(feed.posts[0].id.uuidString, "11111111-1111-1111-1111-111111111111")
        XCTAssertEqual(feed.posts[0].caption, "First integration test post")
        XCTAssertEqual(feed.posts[0].author.username, "hakim.aliyev")
        XCTAssertEqual(feed.posts[0].likeCount, 12)
        XCTAssertEqual(feed.posts[0].commentCount, 3)
        XCTAssertEqual(feed.posts[0].isLiked, false)
        XCTAssertEqual(feed.posts[0].isSaved, true)
        XCTAssertTrue(feed.hasMore)
        XCTAssertEqual(feed.nextCursor?.postId.uuidString, "FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF")
    }
    func testLoadGlobalFeedWithCursorSendsPaginationParameters() async throws {
        let beforeId = UUID(uuidString: "FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF")!

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let beforeCreatedAt = formatter.date(from: "2026-05-16T08:25:40.000Z")!
        let limit = 10
        
        MockURLProtocol.handler = { request in
            XCTAssertEqual(request.url?.path, "/rest/v1/rpc/get_global_feed_cursor")
           
            let bodyData = try requestBodyData(from: request)
            guard let json = try JSONSerialization.jsonObject(with: bodyData) as? [String: Any] else {
                throw IntegrationTestError.invalidRequestBody
            }

            XCTAssertEqual(json["limit_param"] as? Int, limit)
            XCTAssertEqual(json["before_id"] as? String, beforeId.uuidString)
            XCTAssertEqual(json["before_created_at"] as? String, beforeCreatedAt.iso8601WithMilliseconds)
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
        
        let sut = FeedService(client: client)

        let feed = try await sut.loadGlobalFeed(
            limit: limit,
            beforeCreatedAt: beforeCreatedAt,
            beforeId: beforeId
        )
        
        XCTAssertEqual(feed.posts.count, 8)
        XCTAssertEqual(feed.nextCursor?.postId.uuidString, "FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF")
    }
    
    func testLoadGlobalFeedWhenServerReturnsErrorThrows() async throws {
        MockURLProtocol.handler = { request in
            
            XCTAssertEqual(request.url?.path, "/rest/v1/rpc/get_global_feed_cursor")
            
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
        let sut = FeedService(client: client)
        
        do{
            let result =   try  await sut.loadGlobalFeed()
            
            XCTFail("Expected loadGlobalFeed to throw")
        }catch{
            XCTAssertNotNil(error)
        }
    }
    func testLoadGlobalFeedWhenServerReturnsInvalidShape() async throws {
        MockURLProtocol.handler = { request in
            
            XCTAssertEqual(request.url?.path, "/rest/v1/rpc/get_global_feed_cursor")
            
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            )!
            
            let data = try TestFixture.data(
                named: "global_feed_invalid_shape",
                subdirectory: "Feed"
            )
            return (response, data)
        }
        let client = SupabaseClient(
            supabaseURL: URL(string: "https://test-project.supabase.co")!,
            supabaseKey: "test-anon-key"
        )
        let sut = FeedService(client: client)
        
        do{
            let result =   try  await sut.loadGlobalFeed()
            
            XCTFail("Expected loadGlobalFeed to throw")
        }catch{
            XCTAssertNotNil(error)
        }
    }
    func testLoadGlobalFeedWhenServerReturnsEmpty() async throws {
        MockURLProtocol.handler = { request in
            
            XCTAssertEqual(request.url?.path, "/rest/v1/rpc/get_global_feed_cursor")
            
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            )!
            
            let data = try TestFixture.data(
                named: "global_feed_empty",
                subdirectory: "Feed"
            )
            return (response, data)
        }
        let client = SupabaseClient(
            supabaseURL: URL(string: "https://test-project.supabase.co")!,
            supabaseKey: "test-anon-key"
        )
        let sut = FeedService(client: client)
        
       
        let result =   try  await sut.loadGlobalFeed()
            
        XCTAssertEqual(result.posts.count, 0)
        XCTAssertNil(result.nextCursor)
        XCTAssertFalse(result.hasMore)
    }
    
}

private enum IntegrationTestError: Error {
    case missingRequestBody
    case invalidRequestBody
}

private func requestBodyData(from request: URLRequest) throws -> Data {
    if let httpBody = request.httpBody {
        return httpBody
    }

    if let stream = request.httpBodyStream {
        stream.open()
        defer { stream.close() }

        var data = Data()
        var buffer = [UInt8](repeating: 0, count: 1024)

        while stream.hasBytesAvailable {
            let bytesRead = stream.read(&buffer, maxLength: buffer.count)

            if bytesRead < 0 {
                throw stream.streamError ?? IntegrationTestError.missingRequestBody
            }

            if bytesRead == 0 {
                break
            }

            data.append(buffer, count: bytesRead)
        }

        if !data.isEmpty {
            return data
        }
    }

    throw IntegrationTestError.missingRequestBody
}
