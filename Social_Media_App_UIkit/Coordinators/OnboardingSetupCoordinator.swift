//
//  ProfileOnboardingSetupCoordinator.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 9/29/25.
//

import UIKit


final class OnboardingSetupCoordinator : Coordinator {
   
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
       print("Show info")
    }
    
    
    
}


protocol OnboardingSetupViewModelDelegate: AnyObject {
    func selectedProfileImage()
}

extension OnboardingSetupCoordinator: OnboardingSetupViewModelDelegate {
    func selectedProfileImage() {
     
        showInfoSelect()
    }
    
    
    
    
}
