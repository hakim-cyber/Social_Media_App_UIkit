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

    private var viewModel: FollowersListViewModel?
    private let user: UserProfile
    private let isCurrentUser: Bool
    private let target: FollowerListTarget
    init(
        navigationController: UINavigationController,
        user:UserProfile,
        isCurrentUser:Bool,
        target:FollowerListTarget
    ) {
        self.navigationController = navigationController
        self.isCurrentUser = isCurrentUser
        self.user = user
        self.target = target
    }

    func start(animated: Bool) {
        let vm = FollowersListViewModel(target: target, selectedUser: user,isCurrentUser: isCurrentUser)
        self.viewModel = vm
        bind(vm)
        let vc = FollowersListViewController(vm: vm)
        self.navigationController.pushViewController(vc, animated: true)

    }

    func showProfile(author: UserFollowItem) {
            let currentId = UserSessionService.shared.currentUser?.id
        let coord:ProfileCoordinator
            if currentId == author.id{
                coord = ProfileCoordinator(
                   navigationController: self.navigationController,
                   target: .me
               )
            }else{

                 coord = ProfileCoordinator(
                    navigationController: self.navigationController,
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
            self?.viewModel?.removeFollower(userId: user.id)
        }
    }
}
