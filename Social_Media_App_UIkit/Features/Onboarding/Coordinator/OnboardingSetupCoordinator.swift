//
//  ProfileOnboardingSetupCoordinator.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 9/29/25.
//

import UIKit

final class OnboardingSetupCoordinator : NavigationCoordinator, ChildCoordinator {
   
    weak var parentCoordinator: ParentCoordinator?
    var navigationController: UINavigationController
    private let dependencies: MainOnboardingDependencies
    private lazy var viewModel = OnboardingSetupViewModel(
        profileService: dependencies.profileService,
        userNameValidator: dependencies.usernameValidator
    )

    init(
        navigationController: UINavigationController,
        dependencies: MainOnboardingDependencies
    ) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }
 
    func start(animated: Bool) {
        viewModel.delegate = self
        showProfileSelect()
    }
    func showProfileSelect(){
        let vc = ProfileImageSelectView(viewModel: viewModel)
      
        navigationController.setViewControllers([vc], animated: true)
    }
    func showInfoSelect(){
      
        let vc = ProfileInfoSetupView(viewModel: viewModel)
      
        navigationController.setViewControllers([vc], animated: true)
    }
    
    // MARK: - ChildCoordinator
       func coordinatorDidFinish() {
           parentCoordinator?.childDidFinish(self)
       }
    
}


protocol OnboardingSetupViewModelDelegate: AnyObject {
    func selectedProfileImage()
    func finishedInfoSetup()
}

extension OnboardingSetupCoordinator: OnboardingSetupViewModelDelegate {
    func selectedProfileImage() {
        showInfoSelect()
    }
    func finishedInfoSetup() {
     
        parentCoordinator?.childDidFinish(self)
    }
    
    
    
    
}
