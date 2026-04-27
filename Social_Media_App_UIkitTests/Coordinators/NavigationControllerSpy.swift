//
//  NavigationControllerSpy.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 4/27/26.
//


import UIKit

final class NavigationControllerSpy: UINavigationController {
    private(set) var setViewControllersCalls: [[UIViewController]] = []
    private(set) var pushedViewControllers: [UIViewController] = []
    private(set) var presentedViewControllerSpy: UIViewController?
    private(set) var popCallCount = 0
    private(set) var dismissCallCount = 0

    override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        setViewControllersCalls.append(viewControllers)
        super.setViewControllers(viewControllers, animated: false)
    }

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        pushedViewControllers.append(viewController)
        super.pushViewController(viewController, animated: false)
    }

    override func present(_ viewControllerToPresent: UIViewController,
                          animated flag: Bool,
                          completion: (() -> Void)? = nil) {
        presentedViewControllerSpy = viewControllerToPresent
        completion?()
    }

    override func popViewController(animated: Bool) -> UIViewController? {
        popCallCount += 1
        return super.popViewController(animated: false)
    }

    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        dismissCallCount += 1
        completion?()
    }
}
