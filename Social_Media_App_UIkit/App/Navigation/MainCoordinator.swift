//
//  MainCoordinator.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 10/1/25.
//

import UIKit
import Supabase

final class MainCoordinator: NSObject, Coordinator, ParentCoordinator {

    var childCoordinators: [Coordinator] = []

    private let onboardingDependencies: MainOnboardingDependencies
    private let feedDependencies: MainFeedDependencies
    private let searchDependencies: MainSearchDependencies
    private let profileDependencies: MainProfileDependencies
    private let createPostDependencies: MainCreatePostDependencies
    private let startResolver: any MainStartResolving

    let tabBarController = UITabBarController()

    private let feedNav = UINavigationController()
    private let profileNav = UINavigationController()
    private let searchNav = UINavigationController()

    private var feedCoordinator: FeedCoordinator?
    private var profileCoordinator: ProfileCoordinator?
    private var searchCoordinator: SearchProfileCoordinator?
    private var onboardingCoordinator: OnboardingSetupCoordinator?
    private var createPostCoordinator: CreatePostCoordinator?
    private var onboardingNav: UINavigationController?
    let feedTabIndex: Int = 0
    let searchTabIndex: Int = 1
    let profileTabIndex: Int = 3

    init(
        dependencies: MainFlowDependencies,
        startResolver: (any MainStartResolving)? = nil
    ) {
        self.onboardingDependencies = dependencies.onboarding
        self.feedDependencies = dependencies.feed
        self.searchDependencies = dependencies.search
        self.profileDependencies = dependencies.profile
        self.createPostDependencies = dependencies.createPost
        self.startResolver = startResolver ?? MainStartResolver(profileService: dependencies.profile.profileService)
    }

    func start(animated: Bool) {
        Task { [weak self] in
            guard let self else { return }
            let destination = await startResolver.resolve()

            await MainActor.run {
                switch destination {
                case .mainTabs:
                    self.showMainView(animated: false)
                case .onboarding:
                    self.showOnboardingSetup()
                }
            }
        }
    }

    private func setupTabs() {
        let feedCoordinator = makeFeedCoordinator(navigationController: feedNav)
        feedCoordinator.parentCoordinator = self
        addChild(feedCoordinator)
        feedCoordinator.start(animated: false)
        self.feedCoordinator = feedCoordinator

        feedNav.tabBarItem = UITabBarItem(
            title: "Feed",
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )

        let searchCoordinator = makeSearchCoordinator(navigationController: searchNav)
        searchCoordinator.parentCoordinator = self
        addChild(searchCoordinator)
        searchCoordinator.start(animated: false)
        self.searchCoordinator = searchCoordinator

        searchNav.tabBarItem = UITabBarItem(
            title: "Search",
            image: UIImage(systemName: "magnifyingglass"),
            selectedImage: UIImage(systemName: "magnifyingglass")
        )

        let profileCoordinator = makeProfileCoordinator(
            navigationController: profileNav,
            target: .me
        )
        profileCoordinator.parentCoordinator = self
        addChild(profileCoordinator)
        profileCoordinator.start(animated: false)
        self.profileCoordinator = profileCoordinator

        profileNav.tabBarItem = UITabBarItem(
            title: "Profile",
            image: UIImage(systemName: "person"),
            selectedImage: UIImage(systemName: "person.fill")
        )

        let createNav = UINavigationController()
        let createItem = UITabBarItem(tabBarSystemItem: .search, tag: 99)
        createItem.image = UIImage(systemName: "plus")
        createItem.selectedImage = UIImage(systemName: "plus")
        createItem.title = nil
        createNav.tabBarItem = createItem

        tabBarController.viewControllers = [feedNav, searchNav, createNav, profileNav]
        tabBarController.delegate = self
        if #available(iOS 26.0, *) {
            tabBarController.tabBarMinimizeBehavior = .onScrollDown
        } else {
            createItem.title = "Post"
        }
    }

    func showMainView(animated: Bool = true) {
        setupTabs()
    }

    func switchToMyProfile() {
        tabBarController.selectedIndex = profileTabIndex
        profileNav.popToRootViewController(animated: false)
    }

    func showProfile(for userId: UUID) {
        feedCoordinator?.showProfile(id: userId)
    }

    private func showOnboardingSetup() {
        let nav = UINavigationController()
        nav.modalPresentationStyle = .fullScreen
        onboardingNav = nav

        let onboarding = makeOnboardingSetupCoordinator(navigationController: nav)
        onboarding.parentCoordinator = self
        addChild(onboarding)
        onboardingCoordinator = onboarding

        onboarding.start(animated: false)
        tabBarController.present(nav, animated: true)
    }

    func childDidFinish(_ child: Coordinator?) {
        childCoordinators.removeAll(where: { $0 === child })

        if child === onboardingCoordinator {
            onboardingCoordinator = nil
            onboardingNav?.dismiss(animated: true)
            onboardingNav = nil
            showMainView()
        }

        if child === feedCoordinator {
            feedCoordinator = nil
        }
        if child === createPostCoordinator {
            createPostCoordinator = nil
        }
    }

    private func presentCreateFlow() {
        guard let presenter = tabBarController.presentedViewController ?? tabBarController.selectedViewController else {
            return
        }

        let coord = makeCreatePostCoordinator(presenter: presenter)
        coord.parentCoordinator = self
        addChild(coord)
        createPostCoordinator = coord
        coord.start(animated: true)
    }
}

private extension MainCoordinator {
    func makeProfileCoordinator(
        navigationController: UINavigationController,
        target: ProfileTarget
    ) -> ProfileCoordinator {
        ProfileCoordinator(
            navigationController: navigationController,
            dependencies: profileDependencies,
            feedDependencies: feedDependencies,
            target: target
        )
    }

    func makeFeedCoordinator(navigationController: UINavigationController) -> FeedCoordinator {
        FeedCoordinator(
            navigationController: navigationController,
            dependencies: feedDependencies,
            profileDependencies: profileDependencies
        )
    }

    func makeSearchCoordinator(navigationController: UINavigationController) -> SearchProfileCoordinator {
        SearchProfileCoordinator(
            navigationController: navigationController,
            dependencies: searchDependencies,
            profileDependencies: profileDependencies,
            feedDependencies: feedDependencies
        )
    }

    func makeOnboardingSetupCoordinator(
        navigationController: UINavigationController
    ) -> OnboardingSetupCoordinator {
        OnboardingSetupCoordinator(
            navigationController: navigationController,
            dependencies: onboardingDependencies
        )
    }

    func makeCreatePostCoordinator(presenter: UIViewController) -> CreatePostCoordinator {
        CreatePostCoordinator(
            presenter: presenter,
            dependencies: createPostDependencies
        )
    }
}

extension MainCoordinator: UITabBarControllerDelegate {
    func tabBarController(
        _ tabBarController: UITabBarController,
        shouldSelect viewController: UIViewController
    ) -> Bool {
        if viewController.tabBarItem.tag == 99 {
            presentCreateFlow()
            return false
        }

        return true
    }
}
