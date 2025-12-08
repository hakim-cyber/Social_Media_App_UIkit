import UIKit

// MARK: - Base Coordinator
/// Minimal coordinator – just “something that can start a flow”
protocol Coordinator: AnyObject {
    /// Entry point for the flow
    func start(animated: Bool)
}

// MARK: - Navigation-based Coordinator
/// Coordinators that manage a UINavigationController
protocol NavigationCoordinator: Coordinator {
    var navigationController: UINavigationController { get }

    func popViewController(
        animated: Bool,
        useCustomAnimation: Bool,
        transitionType: CATransitionType
    )
}

extension NavigationCoordinator {
    func popViewController(
        animated: Bool,
        useCustomAnimation: Bool = false,
        transitionType: CATransitionType = .push
    ) {
        guard useCustomAnimation else {
            navigationController.popViewController(animated: animated)
            return
        }

        let transition = CATransition()
        transition.duration = 0.25
        transition.type = transitionType          // .push / .moveIn / etc.
        transition.subtype = .fromLeft            // adjust as needed
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        navigationController.view.layer.add(transition, forKey: kCATransition)
        navigationController.popViewController(animated: false)
    }
}

// MARK: - Parent / Child

/// All “owning” coordinators should conform to this
protocol ParentCoordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }

    func addChild(_ child: Coordinator?)
    func childDidFinish(_ child: Coordinator?)
}

extension ParentCoordinator {
    func addChild(_ child: Coordinator?) {
        guard let child else { return }
        childCoordinators.append(child)
    }

    func childDidFinish(_ child: Coordinator?) {
        guard let child else { return }
        childCoordinators.removeAll { $0 === child }
    }
}

/// All child coordinators should conform to this
protocol ChildCoordinator: Coordinator {
    var parentCoordinator: ParentCoordinator? { get set }
    func coordinatorDidFinish()
}
