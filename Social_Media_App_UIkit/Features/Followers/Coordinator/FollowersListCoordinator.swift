//
//  FollowersListCoordinator.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 12/29/25.
//

import UIKit
import Supabase

final class FollowersListCoordinator: NavigationCoordinator,ParentCoordinator, ChildCoordinator {

    // MARK: - ParentCoordinator
    var childCoordinators: [Coordinator] = []

    // MARK: - ChildCoordinator
    weak var parentCoordinator: ParentCoordinator?

    // MARK: - Coordinator
    var navigationController: UINavigationController

    private let dependencies: MainProfileDependencies
    private let feedDependencies: MainFeedDependencies
    private let user: UserProfile
    private let isCurrentUser: Bool
    private let target: FollowerListTarget
    private lazy var viewModel = FollowersListViewModel(
        target: target,
        selectedUser: user,
        isCurrentUser: isCurrentUser,
        currentUserId: dependencies.sessionStore.currentUser?.id,
        followService: dependencies.followService
    )

    init(
        navigationController: UINavigationController,
        dependencies: MainProfileDependencies,
        feedDependencies: MainFeedDependencies,
        user: UserProfile,
        isCurrentUser: Bool,
        target: FollowerListTarget
    ) {
        self.navigationController = navigationController
        self.dependencies = dependencies
        self.feedDependencies = feedDependencies
        self.user = user
        self.isCurrentUser = isCurrentUser
        self.target = target
    }

    func start(animated: Bool) {
        bind(viewModel)
        let vc = FollowersListViewController(vm: viewModel)
        self.navigationController.pushViewController(vc, animated: true)

    }

    func showProfile(author: UserFollowItem) {
        let currentId = dependencies.sessionStore.currentUser?.id
        let coord: ProfileCoordinator
        if currentId == author.id {
            coord = ProfileCoordinator(
                navigationController: self.navigationController,
                dependencies: dependencies,
                feedDependencies: feedDependencies,
                target: .me
            )
        } else {
            coord = ProfileCoordinator(
                navigationController: self.navigationController,
                dependencies: dependencies,
                feedDependencies: feedDependencies,
                target: .user(id: author.id)
            )
        }
        coord.parentCoordinator = self
        self.addChild(coord)
        coord.startPush(animated: true)

    }
    deinit {
        print("FeedCoordinator deinit")
    }

    func coordinatorDidFinish() {
        print("FeedCoordinator finished")
        parentCoordinator?.childDidFinish(self)
    }

    private func bind(_ vm: FollowersListViewModel) {
        vm.onRoute = { [weak self] route in
            DispatchQueue.main.async {
                self?.handle(route)
            }
        }
    }

    private func handle(_ route: FollowerListRoute) {
        switch route {
        case .openProfile(let user):
            showProfile(author: user)
        case .showMore(let user):
            showMoreActions(for: user)
        }
    }

    private func showMoreActions(for user: UserFollowItem) {
        MoreSheetPresenter.showFollower(user, from: self.navigationController) { [weak self] in
            self?.viewModel.removeFollower(userId: user.id)
        }
    }
}
