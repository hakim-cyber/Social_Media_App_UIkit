//
//  ProfileCoordinator.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 12/24/25.
//

import Foundation


import UIKit

final class ProfileCoordinator:NSObject, NavigationCoordinator,ParentCoordinator, ChildCoordinator,UINavigationControllerDelegate {

    // MARK: - ParentCoordinator
    var childCoordinators: [Coordinator] = []

    // MARK: - ChildCoordinator
    weak var parentCoordinator: ParentCoordinator?

    // MARK: - Coordinator
    var navigationController: UINavigationController

    private let dependencies: MainProfileDependencies
    private let feedDependencies: MainFeedDependencies
    private let target: ProfileTarget
    private lazy var viewModel = ProfileViewModel(
        target: target,
        sessionStore: dependencies.sessionStore,
        profileService: dependencies.profileService,
        followService: dependencies.followService,
        postQueryService: dependencies.postQueryService,
        postService: dependencies.postActionService,
        translationController: PostTranslationController(service: dependencies.translationService),
        sessionManager: AuthSessionManager(authService: dependencies.authService)
    )

    private weak var profileVC: UIViewController?
    init(
        navigationController: UINavigationController,
        dependencies: MainProfileDependencies,
        feedDependencies: MainFeedDependencies,
        target:ProfileTarget
    ) {
        self.navigationController = navigationController
        self.dependencies = dependencies
        self.feedDependencies = feedDependencies
        self.target = target
    }



    deinit {
        print("FeedCoordinator deinit")
    }

    func coordinatorDidFinish() {
        print("FeedCoordinator finished")
        parentCoordinator?.childDidFinish(self)
    }
    func start(animated: Bool) {
        startRooot(animated: animated)
    }
    private func startRooot(animated: Bool) {
        bind(viewModel)

        let vc = ProfileViewController(vm: viewModel)
        navigationController.setViewControllers([vc], animated: animated)
    }
    func startPush(animated: Bool) {
        bind(viewModel)

        let vc = ProfileViewController(vm: viewModel)
        profileVC = vc
        navigationController.delegate = self
        navigationController.pushViewController(vc, animated: animated)
    }
    func navigationController(_ navigationController: UINavigationController,
                                  didShow viewController: UIViewController,
                                  animated: Bool) {
            guard let profileVC else { return }

            // if profileVC is not in nav stack anymore => popped
            if !navigationController.viewControllers.contains(profileVC) {
                parentCoordinator?.childDidFinish(self)
            }
        }

    private func bind(_ vm: ProfileViewModel) {
        vm.onRoute = { [weak self] route in
            DispatchQueue.main.async {
                self?.handle(route)
            }
        }
    }
}

extension ProfileCoordinator {
    private func handle(_ route: ProfileRoute) {
        switch route {
        case .editProfile:
            showEditProfile()
        case .message:
            break
        case .more:
            showMoreActions()
        case .shareProfile:
            shareProfile()
        case .openPost(let post):
            showSelectedPost(post)
        case .followers:
            showFollowers()
        case .following:
            showFollowings()
        }
    }

    private func showMoreActions() {
        guard let profile = viewModel.profile else { return }
        MoreSheetPresenter.showProfile(profile, from: self.navigationController) { [weak self] in
            Task {
                await self?.viewModel.logout()
            }
        }
    }

    private func showFollowers() {
        guard let profile = viewModel.profile else { return }
        let coord = FollowersListCoordinator(
            navigationController: navigationController,
            dependencies: dependencies,
            feedDependencies: feedDependencies,
            user: profile,
            isCurrentUser: viewModel.isCurrentUser,
            target: .followers
        )
        coord.parentCoordinator = self
        self.addChild(coord)
        coord.start(animated: true)
    }

    private func showFollowings() {
        guard let profile = viewModel.profile else { return }
        let coord = FollowersListCoordinator(
            navigationController: navigationController,
            dependencies: dependencies,
            feedDependencies: feedDependencies,
            user: profile,
            isCurrentUser: viewModel.isCurrentUser,
            target: .following
        )
        coord.parentCoordinator = self
        self.addChild(coord)
        coord.start(animated: true)
    }

    private func showEditProfile() {
        guard let profile = viewModel.profile else { return }
        let vm = EditProfileViewModel(
            profileService: dependencies.profileService,
            userNameValidator: dependencies.usernameValidator
        )

        vm.configure(with: profile)
        vm.onProfileUpdated = { [weak self] newUser in
            self?.navigationController.popViewController(animated: true)
            self?.viewModel.updateProfile(profile: newUser)
        }
        let vc = ProfileEditViewController(viewModel: vm)
        self.navigationController.pushViewController(vc, animated: true)
    }

    private func showSelectedPost(_ post: Post) {
        let coord = ProfilePostFeedCordinator(
            navigationController: navigationController,
            profileDependencies: dependencies,
            feedDependencies: feedDependencies,
            viewModel: viewModel,
            selectedPost: post
        )

        coord.parentCoordinator = self
        self.addChild(coord)
        coord.start(animated: true)
    }

    private func shareProfile() {
        guard let profile = viewModel.profile else { return }

        let urlString = "myapp://u/\(profile.id.uuidString)"
        UIPasteboard.general.string = urlString

        // Debug: verify immediately
        print("Copied:", UIPasteboard.general.string ?? "nil")
    }
}
