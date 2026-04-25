//
//  MockSearchService.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 4/25/26.
//

@testable import Social_Media_App_UIkit


class MockSearchService: SearchServicing {
    var result: Result<[UserSummary], Error> = .success([])
    var called: Bool = false
    func searchUsers(query: String, limit: Int) async throws -> [UserSummary] {
        called = true
        return try result.get()
    }
    
}
