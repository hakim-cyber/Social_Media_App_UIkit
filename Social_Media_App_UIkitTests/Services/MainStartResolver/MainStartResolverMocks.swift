//
//  MainStartResolverMocks.swift
//  Social_Media_App_UIkitTests
//
//  Created by Codex on 4/26/26.
//

import UIKit
@testable import Social_Media_App_UIkit

final class MainStartResolverMockProfileService: ProfileServicing {
    var checkIfUserHasProfileResult: Result<Bool, Error> = .success(false)

    private(set) var checkIfUserHasProfileCallCount = 0

    func checkIfUserHasProfile() async throws -> Bool {
        checkIfUserHasProfileCallCount += 1
        return try checkIfUserHasProfileResult.get()
    }

    func fetchUserProfile(id: UUID) async throws -> UserProfile {
        throw MainStartResolverTestError("Not used in tests")
    }

    func fetchProfileCounts(userId: UUID) async throws -> ProfileCounts {
        throw MainStartResolverTestError("Not used in tests")
    }

    func createNewProfile(
        username: String,
        fullName: String,
        bio: String?,
        avatarImage: UIImage?
    ) async throws -> UserProfile {
        throw MainStartResolverTestError("Not used in tests")
    }

    func updateProfile(
        username: String,
        fullName: String,
        bio: String?,
        avatarImage: UIImage?
    ) async throws -> UserProfile {
        throw MainStartResolverTestError("Not used in tests")
    }
}

struct MainStartResolverTestError: LocalizedError {
    let message: String

    init(_ message: String) {
        self.message = message
    }

    var errorDescription: String? {
        message
    }
}
