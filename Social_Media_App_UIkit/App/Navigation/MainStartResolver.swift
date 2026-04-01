//
//  MainStartResolver.swift
//  Social_Media_App_UIkit
//
//  Created by Codex on 3/31/26.
//

import Foundation

enum MainStartDestination {
    case mainTabs
    case onboarding
}

protocol MainStartResolving {
    func resolve() async -> MainStartDestination
}

struct MainStartResolver: MainStartResolving {
    private let profileService: any ProfileServicing

    init(profileService: any ProfileServicing) {
        self.profileService = profileService
    }

    func resolve() async -> MainStartDestination {
        do {
            let userHasProfile = try await profileService.checkIfUserHasProfile()
            return userHasProfile ? .mainTabs : .onboarding
        } catch {
            return .onboarding
        }
    }
}
