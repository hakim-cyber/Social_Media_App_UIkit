//
//  SearchProfileCoordinator.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 12/27/25.
//

import UIKit
import SwiftUI
import Supabase

final class SearchProfileCoordinator: NavigationCoordinator,ParentCoordinator, ChildCoordinator {

    // MARK: - ParentCoordinator
    var childCoordinators: [Coordinator] = []

    // MARK: - ChildCoordinator
    weak var parentCoordinator: ParentCoordinator?

    // MARK: - Coordinator
    var navigationController: UINavigationController

    private var viewModel: SearchViewModel?

    init(
        navigationController: UINavigationController,
    ) {
        self.navigationController = navigationController

    }

    func start(animated: Bool) {
        let vm = SearchViewModel()
        vm.onRoute = { [weak self] route in
            DispatchQueue.main.async {
                switch route {
                case .openProfile(let id):
                    self?.showProfile(userId: id)
                }
            }
        }


        let view = SearchProfileView(vm: vm)
                let host = UIHostingController(rootView: view)
        self.viewModel = vm


            navigationController.setViewControllers([host], animated: animated)


    }
    func showProfile(userId: UUID) {

            let currentId = UserSessionService.shared.currentUser?.id

            if currentId == userId,
               let main = self.parentCoordinator as? MainCoordinator {
                main.switchToMyProfile()
                return
            }

            let coord = ProfileCoordinator(
                navigationController: self.navigationController,
                target: .user(id: userId)
            )
            coord.parentCoordinator = self
            self.addChild(coord)
            coord.startPush(animated: true)

    }
    deinit {

    }

    func coordinatorDidFinish() {

        parentCoordinator?.childDidFinish(self)
    }
}
