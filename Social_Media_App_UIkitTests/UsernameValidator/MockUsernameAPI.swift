//
//  MockUsernameAPI.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 4/25/26.
//
@testable import Social_Media_App_UIkit

struct MockUsernameAPI: UsernameAPI {
    var result: Result<Bool, Error>

    func isUsernameAvailable(_ username: String) async throws -> Bool {
        try result.get()
    }
}
