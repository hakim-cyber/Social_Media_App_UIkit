//
//  MainStartResolverTests.swift
//  Social_Media_App_UIkitTests
//
//  Created by Codex on 4/26/26.
//

import Testing
@testable import Social_Media_App_UIkit

struct MainStartResolverTests {

    @Test
    func test_resolve_whenProfileExists_returnsMainTabs() async {
        let profileService = MainStartResolverMockProfileService()
        profileService.checkIfUserHasProfileResult = .success(true)
        let sut = await MainStartResolver(profileService: profileService)

        let destination = await sut.resolve()

        #expect(matchesMainStartDestination(destination, expected: .mainTabs))
        #expect(profileService.checkIfUserHasProfileCallCount == 1)
    }

    @Test
    func test_resolve_whenProfileDoesNotExist_returnsOnboarding() async {
        let profileService = MainStartResolverMockProfileService()
        profileService.checkIfUserHasProfileResult = .success(false)
        let sut = await MainStartResolver(profileService: profileService)

        let destination = await sut.resolve()

        #expect(matchesMainStartDestination(destination, expected: .onboarding))
        #expect(profileService.checkIfUserHasProfileCallCount == 1)
    }

    @Test
    func test_resolve_whenServiceThrows_returnsOnboarding() async {
        let profileService = MainStartResolverMockProfileService()
        profileService.checkIfUserHasProfileResult = .failure(MainStartResolverTestError("backend failed"))
        let sut = await MainStartResolver(profileService: profileService)

        let destination = await sut.resolve()

        #expect(matchesMainStartDestination(destination, expected: .onboarding))
        #expect(profileService.checkIfUserHasProfileCallCount == 1)
    }
}
