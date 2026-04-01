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

    private let window: UIWindow
    private var cancellables = Set<AnyCancellable>()
    private var hasStarted = false

    private let container: AppContainer

    private var authCoordinator: AuthCoordinator?
    private var mainCoordinator: MainCoordinator?

    private enum RootMode {
        case normal
        case passwordReset
    }

    private enum RootFlow: Equatable {
        case auth
        case main
    }

    private var rootMode: RootMode = .normal
    private var currentRootFlow: RootFlow?
    private var didPresentPasswordReset = false

    init(window: UIWindow, container: AppContainer) {
        self.window = window
        self.container = container
        self.navigationController = UINavigationController()
    }

    func start(animated: Bool = true) {
        guard !hasStarted else { return }
        hasStarted = true

        window.rootViewController = navigationController
        window.makeKeyAndVisible()

        listenToAuthChanges()
    }

    private func listenToAuthChanges() {
        container.sessionStore.isLoggedInPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] signedIn in
                guard let self else { return }

                if self.rootMode == .passwordReset {
                    self.transition(to: .auth)
                    self.presentPasswordResetIfNeeded()
                    return
                }

                self.transition(to: signedIn ? .main : .auth)
            }
            .store(in: &cancellables)
    }

    private func transition(to target: RootFlow) {
        guard !isShowingRoot(target) else { return }

        tearDownCurrentRoot()

        switch target {
        case .auth:
            startAuthFlow()
        case .main:
            startMainFlow()
        }

        currentRootFlow = target
    }

    private func isShowingRoot(_ flow: RootFlow) -> Bool {
        switch flow {
        case .auth:
            return currentRootFlow == .auth &&
                authCoordinator != nil &&
                window.rootViewController === navigationController

        case .main:
            guard let mainCoordinator else { return false }
            return currentRootFlow == .main &&
                window.rootViewController === mainCoordinator.tabBarController
        }
    }

    private func tearDownCurrentRoot() {
        window.rootViewController?.dismiss(animated: false)

        // AppCoordinator directly owns only the two root flows.
        childCoordinators.removeAll { coordinator in
            coordinator is AuthCoordinator || coordinator is MainCoordinator
        }

        authCoordinator = nil
        mainCoordinator = nil
        currentRootFlow = nil
    }

    private func startAuthFlow() {
        let auth = AuthCoordinator(
            navigationController: navigationController,
            dependencies: container.authFlowDependencies
        )

        authCoordinator = auth
        addChild(auth)

        window.rootViewController = navigationController
        window.makeKeyAndVisible()

        navigationController.setNavigationBarHidden(false, animated: false)
        auth.start(animated: false)
    }

    private func startMainFlow() {
        let main = MainCoordinator(
            dependencies: container.mainFlowDependencies
        )

        mainCoordinator = main
        addChild(main)

        main.start(animated: false)

        window.rootViewController = main.tabBarController
        window.makeKeyAndVisible()
    }

    func handleResetPasswordDeepLink() {
        rootMode = .passwordReset
        didPresentPasswordReset = false

        transition(to: .auth)
        presentPasswordResetIfNeeded()
    }

    private func presentPasswordResetIfNeeded() {
        guard rootMode == .passwordReset else { return }
        guard !didPresentPasswordReset else { return }
        guard authCoordinator != nil else { return }

        didPresentPasswordReset = true

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }

            self.authCoordinator?.showForgotPasswordSetNewPasswordScreen { [weak self] in
                guard let self else { return }

                self.rootMode = .normal
                self.didPresentPasswordReset = false

                let target: RootFlow = self.container.sessionStore.isLoggedIn ? .main : .auth
                self.transition(to: target)
            }
        }
    }

    func showProfile(userid: UUID) {
        mainCoordinator?.showProfile(for: userid)
    }
}
