//
//  CoordinatorFactory.swift
//  Social_Media_App_UIkit
//
//  Created by Hakim Aliyev on 5/23/26.
//

import SwiftUI

final class CoordinatorFactory{
    private let mainDependecies:MainFlowDependencies
    
    init(mainDependecies: MainFlowDependencies) {
        self.mainDependecies = mainDependecies
    }
    
    func makeProfileCoordinator(
        navigationController: UINavigationController,
        target: ProfileTarget
    ) -> ProfileCoordinator {
        ProfileCoordinator(
            navigationController: navigationController,
            dependencies: mainDependecies.profile,
            feedDependencies: mainDependecies.feed,
            target: target
        )
    }

    func makeFeedCoordinator(navigationController: UINavigationController) -> FeedCoordinator {
        FeedCoordinator(
            navigationController: navigationController,
            dependencies: mainDependecies.feed,
            profileDependencies: mainDependecies.profile
        )
    }

    func makeSearchCoordinator(navigationController: UINavigationController) -> SearchProfileCoordinator {
        SearchProfileCoordinator(
            navigationController: navigationController,
            dependencies: mainDependecies.search,
            profileDependencies: mainDependecies.profile,
            feedDependencies: mainDependecies.feed
        )
    }

    func makeOnboardingSetupCoordinator(
        navigationController: UINavigationController
    ) -> OnboardingSetupCoordinator {
        OnboardingSetupCoordinator(
            navigationController: navigationController,
            dependencies: mainDependecies.onboarding
        )
    }

    func makeCreatePostCoordinator(presenter: UIViewController) -> CreatePostCoordinator {
        CreatePostCoordinator(
            presenter: presenter,
            dependencies: mainDependecies.createPost
        )
    }
}
