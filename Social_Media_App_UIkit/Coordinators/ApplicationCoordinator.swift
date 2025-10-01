//
//  ApplicationCoordinator.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 9/20/25.
//

import UIKit
import Combine

final class AppCoordinator: Coordinator {
    var navigationController: UINavigationController
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
        authCoordinator = AuthCoordinator(navigationController: navigationController,onboardingService: onboardingService)
        authCoordinator?.start()
        mainCoordinator = nil
    }
    
    
    private func showMainFlow() {
        mainCoordinator = MainCoordinator(navigationController: navigationController,onboardingService: onboardingService)
        mainCoordinator?.start(animated: true)
        authCoordinator = nil
    }
    
    func showChangePasswordViewController() {
        self.authCoordinator?.showForgotPasswordSetNewPasswordScreen()
    }
}
