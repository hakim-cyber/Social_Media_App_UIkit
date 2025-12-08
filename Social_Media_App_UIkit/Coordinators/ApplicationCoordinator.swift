//
//  ApplicationCoordinator.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 9/20/25.
//

import UIKit
import Combine

final class AppCoordinator: NavigationCoordinator, ParentCoordinator {
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    private var window: UIWindow
    private var cancellables = Set<AnyCancellable>()

    let onboardingService: OnboardingService = .init()
    
    private var authCoordinator: AuthCoordinator?
   private var mainCoordinator: MainCoordinator?

    init(window: UIWindow) {
        self.window = window
        self.navigationController = UINavigationController()
    }

    func start(animated: Bool = true) {
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        listenToAuthChanges()
    }

    private func listenToAuthChanges() {
        UserSessionService.shared.$isLoggedIn
            .receive(on: DispatchQueue.main)
            .sink { [weak self] signedIn in
                if signedIn {
                    self?.showMainFlow()
                } else {
                    self?.showAuthFlow()
                }
            }
            .store(in: &cancellables)
    }

    
    private func showAuthFlow() {
           // Root is our auth nav
           window.rootViewController = navigationController
           window.makeKeyAndVisible()

           // Clean old main
           mainCoordinator = nil

           // Build auth
           let auth = AuthCoordinator(
               navigationController: navigationController,
               onboardingService: onboardingService
           )
           authCoordinator = auth
           addChild(auth)

           auth.start()
           navigationController.setNavigationBarHidden(false, animated: false)
       }
    
    func showMainFlow() {
           let main = MainCoordinator(onboardingService: onboardingService)
           mainCoordinator = main
           addChild(main)

           // Make tab bar the root
           main.start(animated: false)
           window.rootViewController = main.tabBarController
           window.makeKeyAndVisible()

           // Clean auth
           authCoordinator = nil
       }

    func showChangePasswordViewController() {
        self.authCoordinator?.showForgotPasswordSetNewPasswordScreen()
    }
}
