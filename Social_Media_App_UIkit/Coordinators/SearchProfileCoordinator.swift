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
    private var router: SearchRouter?
    
    init(
        navigationController: UINavigationController,
    ) {
        self.navigationController = navigationController
       
    }

    func start(animated: Bool) {
        let vm = SearchViewModel()
       
        let router = SearchRouter()
        router.openProfile = { [weak self] userId in
                   self?.showProfile(userId: userId)
               }
       
        let view = SearchProfileView(vm: vm, router: router)
                let host = UIHostingController(rootView: view)
        self.viewModel = vm
        self.router = router

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
import Combine

final class SearchRouter: ObservableObject {
    var openProfile: ((UUID) -> Void)?
}

