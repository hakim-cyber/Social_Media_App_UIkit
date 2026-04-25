//
//  SearchViewModelTests.swift
//  Social_Media_App_UIkitTests
//
//  Created by aplle on 4/25/26.
//

import XCTest
@testable import Social_Media_App_UIkit

@MainActor
final class SearchViewModelTests: XCTestCase {

    func test_search_withEmptyQuery_clearsState_andDoesNotCallService() async{
        let service = MockSearchService()
        let sut = SearchViewModel(searchService: service)
        sut.query = ""
        await sut.search()
        XCTAssertTrue(sut.results.isEmpty)
        XCTAssertNil(sut.errorMessage)
        XCTAssertFalse(sut.isLoading)
        XCTAssertFalse(service.called)
    }
    
    func test_search_success_setsResults_clearsError_andStopsLoading() async{
        let service = MockSearchService()
        service.result = .success([.mockUser])
        let sut = SearchViewModel(searchService: service)
        sut.query = UserSummary.mockUser.username
        await sut.search()
        XCTAssertEqual(sut.results, [.mockUser])
        XCTAssertNil(sut.errorMessage)
        XCTAssertFalse(sut.isLoading)
        XCTAssertTrue(service.called)
    }
    
    
    func test_search_failure_clearsResults_setsError_andStopsLoading() async{
        struct ExampleError:Error{ }
        
        let service = MockSearchService()
        service.result = .failure( ExampleError())
        let sut = SearchViewModel(searchService: service)
        sut.query = UserSummary.mockUser.username
        await sut.search()
        XCTAssertTrue(sut.results.isEmpty)
        XCTAssertEqual(sut.errorMessage, ExampleError().localizedDescription)
        XCTAssertFalse(sut.isLoading)
        XCTAssertTrue(service.called)
    }
    func test_didSelectUser_routesToOpenProfile_withSelectedUserID() async{
        let service = MockSearchService()
        service.result = .success([.mockUser])
        let sut = SearchViewModel(searchService: service)
        sut.query = UserSummary.mockUser.username
        await sut.search()
        
        var receivedRoute: SearchRoute?
        sut.onRoute = { route in
            receivedRoute = route
        }
        let id = UUID()
        sut.didSelectUser(.mock(id: id))
        
        XCTAssertEqual(receivedRoute, SearchRoute.openProfile(id))
    }
    
    func test_search_withWhitespaceOnlyQuery_behavesLikeEmptyQuery() async{
        let service = MockSearchService()
        service.result = .success([.mockUser])
        let sut = SearchViewModel(searchService: service)
        sut.query = "  "
        await sut.search()
        
        XCTAssertTrue(sut.results.isEmpty)
        XCTAssertFalse(service.called)
        
    }
   
}
