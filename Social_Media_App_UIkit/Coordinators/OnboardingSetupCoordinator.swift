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
    let viewModel = OnboardingSetupViewModel()
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
      
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
