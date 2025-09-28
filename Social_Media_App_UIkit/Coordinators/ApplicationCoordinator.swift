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
//
    private var authCoordinator: AuthCoordinator?
//    private var mainCoordinator: MainCoordinator?

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
        authCoordinator = AuthCoordinator(navigationController: navigationController)
        authCoordinator?.start()
//        mainCoordinator = nil
    }

    private func showMainFlow() {
        // Create main/blank VC
        let blankVC = UIViewController()
        blankVC.view.backgroundColor = .white
        
        // Tap gesture for testing logout
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(blankViewTapped))
        blankVC.view.addGestureRecognizer(tapGesture)
        
        // Add custom bottom-to-top transition
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = .moveIn
        transition.subtype = .fromTop    // slides from bottom to top
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        navigationController.view.layer.add(transition, forKey: kCATransition)
        navigationController.setViewControllers([blankVC], animated: false)
        
        authCoordinator = nil
    }
    @objc private func blankViewTapped() {
        Task {
            do {
                try await AuthService.shared.logout() // or UserSessionService.shared.clearSession()
                print("Logged out")
                
            } catch {
                print("Failed to logout: \(error)")
            }
        }
    }
//    private func showMainFlow() {
//        mainCoordinator = MainCoordinator(navigationController: navigationController)
//        mainCoordinator?.start()
//        authCoordinator = nil
//    }
    
    func showChangePasswordViewController() {
        self.authCoordinator?.showForgotPasswordSetNewPasswordScreen()
    }
}
