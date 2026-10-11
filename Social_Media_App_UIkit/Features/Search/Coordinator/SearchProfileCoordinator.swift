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

    private let dependencies: MainSearchDependencies
    private let profileDependencies: MainProfileDependencies
    private let feedDependencies: MainFeedDependencies
    private lazy var viewModel = SearchViewModel(searchService: dependencies.searchService)

    init(
        navigationController: UINavigationController,
        dependencies: MainSearchDependencies,
        profileDependencies: MainProfileDependencies,
        feedDependencies: MainFeedDependencies
    ) {
        self.navigationController = navigationController
        self.dependencies = dependencies
        self.profileDependencies = profileDependencies
        self.feedDependencies = feedDependencies
    }

    func start(animated: Bool) {
        viewModel.onRoute = { [weak self] route in
            DispatchQueue.main.async {
                switch route {
                case .openProfile(let id):
                    self?.showProfile(userId: id)
                }
            }
        }


        let view = SearchProfileView(vm: self.viewModel)
        let host = UIHostingController(rootView: view)
        navigationController.setViewControllers([host], animated: animated)
    }
    func showProfile(userId: UUID) {
        let currentId = dependencies.sessionStore.currentUser?.id

        if currentId == userId,
           let main = self.parentCoordinator as? MainCoordinator {
            main.switchToMyProfile()
            return
        }

        let coord = ProfileCoordinator(
            navigationController: self.navigationController,
            dependencies: profileDependencies,
            feedDependencies: feedDependencies,
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
