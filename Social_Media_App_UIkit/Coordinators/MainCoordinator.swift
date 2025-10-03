//
//  MainCoordinator.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 10/1/25.
//

import UIKit


class MainCoordinator{
    var childCoordinators: [Coordinator] = []
    
    var navigationController: UINavigationController
    let onboardingService: OnboardingService
    let profileService: ProfileService
    
    init(navigationController: UINavigationController,onboardingService:OnboardingService) {
        self.navigationController = navigationController
        self.onboardingService  = onboardingService
        self.profileService = ProfileService()
    }
    func start(animated: Bool) {
        Task{
           await checkAndShowSetupIfNeeded()
        }
    }
    private func checkAndShowSetupIfNeeded() async {
            do {
                let userHasProfile = try await profileService.checkIfUserHasProfile()
                
                await MainActor.run {
                    if userHasProfile {
                        showMainView()
                    } else {
                        showOnboardingSetup()
                    }
                }
            } catch {
                // Handle error - maybe show error state or retry
                print("Error checking profile: \(error)")
                await MainActor.run {
                    showOnboardingSetup() // Fallback to setup
                }
            }
        }
    func showMainView(){
        // Add custom bottom-to-top transition
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = .moveIn
        transition.subtype = .fromTop    // slides from bottom to top
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        let vc = MainViewController(viewModel: MainCoordinatorViewModel())
        navigationController.view.layer.add(transition, forKey: kCATransition)
        navigationController.setViewControllers([vc], animated: false)
        
    }
    
    private func showOnboardingSetup() {
        let onboardingCoordinator = OnboardingSetupCoordinator(navigationController: navigationController,profileService: profileService)
        onboardingCoordinator.parentCoordinator = self
        self.addChild(onboardingCoordinator)
        onboardingCoordinator.start(animated: true)
    }
    
}
extension MainCoordinator: ParentCoordinator {
    func childDidFinish(_ child: Coordinator?) {
        childCoordinators.removeAll { $0 === child }
                if child is OnboardingSetupCoordinator {
                    showMainView()
                }
    }
    
    
}
