//
//  ProfileCoordinator.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 12/24/25.
//

import Foundation


import UIKit
final class ProfileCoordinator: NavigationCoordinator,ParentCoordinator, ChildCoordinator {
  
    // MARK: - ParentCoordinator
    var childCoordinators: [Coordinator] = []

    // MARK: - ChildCoordinator
    weak var parentCoordinator: ParentCoordinator?

    // MARK: - Coordinator
    var navigationController: UINavigationController

    private let profileService: ProfileService
    private let followService: FollowService

    
    private var viewModel: ProfileViewModel?
    private let target: ProfileTarget
   

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
        let vm = ProfileViewModel(target: target, profileService: profileService, followService: followService)
        self.viewModel = vm

        let vc = ProfileViewController(vm: vm)
        vc.coordinator = self   // via protocol

        navigationController.setViewControllers([vc], animated: animated)
    }
    
}


protocol ProfileCoordinating: AnyObject {
    
    
}

extension ProfileCoordinator:ProfileCoordinating{
    
}
