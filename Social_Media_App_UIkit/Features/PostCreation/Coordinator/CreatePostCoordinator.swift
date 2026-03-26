//
//  CreatePostCoordinator.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 12/9/25.
//

import UIKit
import Combine

final class CreatePostCoordinator: NavigationCoordinator, ChildCoordinator {
    weak var parentCoordinator: ParentCoordinator?

    /// This is the nav (or VC) that will present the create flow.
    private unowned let presenter: UIViewController

    /// This is the modal nav controller we present full-screen.
    var navigationController: UINavigationController
    private var cancellables = Set<AnyCancellable>()
    private var viewModel: CreatePostViewModel?

    init(presenter: UIViewController) {
        self.presenter = presenter
        self.navigationController = UINavigationController()
    }

    func start(animated: Bool) {
        let vm = CreatePostViewModel()
        viewModel = vm
        vm.route
            .receive(on: DispatchQueue.main)
            .sink { [weak self] route in
                self?.handleCreatePostRoute(route: route)
            }
            .store(in: &cancellables)

        let vc = PostCreationViewController(vm: vm)

        navigationController.setViewControllers([vc], animated: false)
        navigationController.modalPresentationStyle = .fullScreen

        presenter.present(navigationController, animated: animated)
    }

    private func finish() {
        navigationController.dismiss(animated: true) { [weak self] in
            guard let self else { return }
            self.cancellables.removeAll()
            self.viewModel = nil
            self.parentCoordinator?.childDidFinish(self)
        }
    }

    func coordinatorDidFinish() {
        finish()
    }

    private func showLocationPicker() {
        guard navigationController.presentedViewController == nil else { return }

        let picker = LocationTextPickerViewController()
        picker.onSelect = { [weak self] locationString in
            self?.viewModel?.setSelectedLocation(locationString)
        }
        let nav = UINavigationController(rootViewController: picker)
        navigationController.present(nav, animated: true)
    }

}

extension CreatePostCoordinator {
    private func handleCreatePostRoute(route: CreatePostRoute) {
        switch route {
        case .cancel:
            finish()
        case .finished:
            finish()
        case .showLocationPicker:
            showLocationPicker()
        }
    }
}
