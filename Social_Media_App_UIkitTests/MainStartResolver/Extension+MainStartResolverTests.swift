//
//  Extension+MainStartResolverTests.swift
//  Social_Media_App_UIkitTests
//
//  Created by Codex on 4/26/26.
//

import Testing
@testable import Social_Media_App_UIkit

extension MainStartResolverTests {
    func matchesMainStartDestination(
        _ received: MainStartDestination,
        expected: MainStartDestination
    ) -> Bool {
        switch (received, expected) {
        case (.mainTabs, .mainTabs), (.onboarding, .onboarding):
            return true
        default:
            return false
        }
    }
}
