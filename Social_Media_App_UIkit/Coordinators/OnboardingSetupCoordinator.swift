//
//  ProfileOnboardingSetupCoordinator.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 9/29/25.
//

import UIKit


final class OnboardingSetupCoordinator : Coordinator {
    weak var parentCoordinator: ParentCoordinator?
    var navigationController: UINavigationController
    let profileService: ProfileService
    let viewModel:OnboardingSetupViewModel
    init(navigationController: UINavigationController,profileService:ProfileService) {
        self.navigationController = navigationController
        self.profileService = profileService
        self.viewModel = .init(profileService: profileService)
      
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
