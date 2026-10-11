//
//  OnboardingServiceMock.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 4/27/26.
//


@testable import Social_Media_App_UIkit

final class OnboardingServiceMock: OnboardingServicing {
    var hasSeenWelcome: Bool
    private(set) var setHasSeenWelcomeCallCount = 0

    init(hasSeenWelcome: Bool) {
        self.hasSeenWelcome = hasSeenWelcome
    }

    func setHasSeenWelcome() {
        hasSeenWelcome = true
        setHasSeenWelcomeCallCount += 1
    }

    func resetHasSeenWelcome() {
        hasSeenWelcome = false
    }
}
