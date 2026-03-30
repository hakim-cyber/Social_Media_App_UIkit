//
//  ProfileCoordinator.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 12/24/25.
//

import Foundation


import UIKit
import Combine
final class ProfileCoordinator:NSObject, NavigationCoordinator,ParentCoordinator, ChildCoordinator,UINavigationControllerDelegate {

    // MARK: - ParentCoordinator
    var childCoordinators: [Coordinator] = []

    // MARK: - ChildCoordinator
    weak var parentCoordinator: ParentCoordinator?

    // MARK: - Coordinator
    var navigationController: UINavigationController

    private let profileService: ProfileService
    private let followService: FollowService


    private var viewModel: ProfileViewModel?
    private var cancellables = Set<AnyCancellable>()
    private let target: ProfileTarget

    private weak var profileVC: UIViewController?
    init(
        navigationController: UINavigationController,
        profileService: ProfileService = .init(),
        followService: FollowService = .init(),
        target:ProfileTarget
    ) {
        self.navigationController = navigationController
        self.followService = followService
        self.profileService = profileService
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
        let vm = ProfileViewModel(target: target, profileService: profileService, followService: followService)
        self.viewModel = vm
        bind(vm)

        let vc = ProfileViewController(vm: vm)
        navigationController.setViewControllers([vc], animated: animated)
    }
    func startPush(animated: Bool) {
        let vm = ProfileViewModel(target: target, profileService: profileService, followService: followService)
        self.viewModel = vm
        bind(vm)

        let vc = ProfileViewController(vm: vm)
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
        cancellables.removeAll()
        vm.route
            .receive(on: DispatchQueue.main)
            .sink { [weak self] route in
                self?.handle(route)
            }
            .store(in: &cancellables)
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
        guard let profile = viewModel?.profile else { return }
        MoreSheetPresenter.showProfile(profile, from: self.navigationController) { [weak self] in
            Task {
                await self?.viewModel?.logout()
            }
        }
    }

    private func showFollowers() {
        guard let profile = viewModel?.profile else { return }
        let coord = FollowersListCoordinator(navigationController: navigationController, user: profile, isCurrentUser: target == .me ? true : false, target: .followers)
        coord.parentCoordinator = self
        self.addChild(coord)
        coord.start(animated: true)
    }

    private func showFollowings() {
        guard let profile = viewModel?.profile else { return }
        let coord = FollowersListCoordinator(navigationController: navigationController, user: profile, isCurrentUser: target == .me ? true : false,target: .following)
        coord.parentCoordinator = self
        self.addChild(coord)
        coord.start(animated: true)
    }

    private func showEditProfile() {
        guard let profile = viewModel?.profile else { return }
        let vm = EditProfileViewModel(profileService: profileService)

        vm.configure(with: profile)
        vm.onProfileUpdated = { [weak self] newUser in
            self?.navigationController.popViewController(animated: true)
            self?.viewModel?.updateProfile(profile: newUser)
        }
        let vc = ProfileEditViewController(viewModel: vm)
        self.navigationController.pushViewController(vc, animated: true)
    }

    private func showSelectedPost(_ post: Post) {
        guard let viewModel else{return}
       let coord = ProfilePostFeedCordinator(navigationController: navigationController, viewModel: viewModel, selectedPost: post)

        coord.parentCoordinator = self
        self.addChild(coord)
        coord.start(animated: true)
    }

    private func shareProfile() {
        guard let profile = viewModel?.profile else { return }

        let urlString = "myapp://u/\(profile.id.uuidString)"
        UIPasteboard.general.string = urlString

        // Debug: verify immediately
        print("Copied:", UIPasteboard.general.string ?? "nil")
    }
}
