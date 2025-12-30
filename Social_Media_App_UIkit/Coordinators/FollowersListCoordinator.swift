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
    private let target: FollowerListTarget
    init(
        navigationController: UINavigationController,
        user:UserProfile,
        target:FollowerListTarget
    ) {
        self.navigationController = navigationController
      
        self.user = user
        self.target = target
    }

    func start(animated: Bool) {
        let vm = FollowersListViewModel(target: target, selectedUser: user)
       let vc = FollowersListViewController(vm: vm)
        vc.coordinator = self
        self.navigationController.pushViewController(vc, animated: true)
        
    }

    func showProfile(author: UserSummary) {
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
}

protocol FollowerListCoordinating: AnyObject {
    func didTapProfile(user: UserSummary)
}
extension FollowersListCoordinator:FollowerListCoordinating{
    func didTapProfile(user: UserSummary) {
        self.showProfile(author: user)
    }
}
