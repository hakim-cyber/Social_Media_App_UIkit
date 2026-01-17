//
//  CreatePostCoordinator.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 12/9/25.
//

import UIKit
import UIKit

final class CreatePostCoordinator: NavigationCoordinator, ChildCoordinator {
  

    weak var parentCoordinator: ParentCoordinator?

    /// This is the nav (or VC) that will present the create flow.
    private unowned let presenter: UIViewController

    /// This is the modal nav controller we present full-screen.
    var navigationController: UINavigationController

    private var viewModel: CreatePostViewModel?
    init(presenter: UIViewController) {
        self.presenter = presenter
        self.navigationController = UINavigationController()
    }

    func start(animated: Bool) {
        // 1) Build VM & VC
        let vm = CreatePostViewModel()
        self.viewModel = vm
        vm.coordinator = self
        let vc = PostCreationViewController(vm: vm)
        
       

        // 2) Configure modal nav
        navigationController.setViewControllers([vc], animated: false)
        navigationController.modalPresentationStyle = .fullScreen
        

        // 3) Present full-screen
        presenter.present(navigationController, animated: animated)
    }

    private func finish() {
        navigationController.dismiss(animated: true) { [weak self] in
            guard let self else { return }
            self.parentCoordinator?.childDidFinish(self)
        }
    }
    func coordinatorDidFinish() {
        finish()
    }
    
}

// MARK: - Pager delegate -> Coordinator closes flow
extension CreatePostCoordinator: CreatePostDelegate {
    func tappedCancelCreate() {
        finish()
    }
    func finishedCreatingPost(post: Post) {
        finish()
    }
}

protocol CreatePostDelegate:AnyObject{
    func tappedCancelCreate()
    func finishedCreatingPost(post:Post)
}
