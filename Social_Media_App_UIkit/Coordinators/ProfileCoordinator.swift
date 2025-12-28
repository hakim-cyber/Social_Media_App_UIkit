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

    private let profileService: ProfileService
    private let followService: FollowService

    
    private var viewModel: ProfileViewModel?
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
        
        let vc = ProfileViewController(vm: vm)
        vc.coordinator = self   // via protocol
     
     
        navigationController.setViewControllers([vc], animated: animated)
     Task{
       await  vm.start()
     }
    }
    func startPush(animated: Bool) {
            let vm = ProfileViewModel(target: target, profileService: profileService, followService: followService)
            self.viewModel = vm

            let vc = ProfileViewController(vm: vm)
            vc.coordinator = self
            profileVC = vc

            navigationController.delegate = self
            navigationController.pushViewController(vc, animated: animated)

            Task { await vm.start() }
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
}


protocol ProfileCoordinating: AnyObject {
    func didTapEditProfile()
    func didTapMessage()
    func didTapShareProfile()
    func didSelectPostCell(post: Post)
    
}

extension ProfileCoordinator:ProfileCoordinating{
    func didTapEditProfile() {
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
    func didTapMessage() {
        
    }
    func didSelectPostCell(post: Post) {
        guard let viewModel else{return}
       let coord = ProfilePostFeedCordinator(navigationController: navigationController, viewModel: viewModel, selectedPost: post)
        
        coord.parentCoordinator = self
        self.addChild(coord)
        coord.start(animated: true)
    }
    func didTapShareProfile() {
        
    }
}
