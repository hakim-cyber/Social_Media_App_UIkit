//
//  Coordinator.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 9/20/25.
//


import UIKit

protocol Coordinator: AnyObject {
    /// The navigation controller for the coordinator
    var navigationController: UINavigationController { get set }
    
    /**
     The Coordinator takes control and activates itself.
     - Parameters:
        - animated: Set the value to true to animate the transition. Pass false if you are setting up a navigation controller before its view is displayed.
     
    */
    func start(animated: Bool)
    
    /**
        Pops out the active View Controller from the navigation stack.
        - Parameters:
            - animated: Set this value to true to animate the transition.
     */
    func popViewController(animated: Bool, useCustomAnimation: Bool, transitionType: CATransitionType)
}

extension Coordinator {
    /**
     Pops the top view controller from the navigation stack and updates the display.
     
     - Parameters:
        - animated: Set this value to true to animate the transition.
        - useCustomAnimation: Set to true if you want a transition from top to bottom.
     */
    func popViewController(animated: Bool, useCustomAnimation: Bool = false, transitionType: CATransitionType = .push) {
      
            navigationController.popViewController(animated: animated)
        
    }
    
    
}

/// All the top-level coordinators should conform to this protocol
protocol ParentCoordinator: Coordinator {
    /// Each Coordinator can have its own children coordinators
    var childCoordinators: [Coordinator] { get set }
    /**
     Adds the given coordinator to the list of children.
     - Parameters:
        - child: A coordinator.
     */
    func addChild(_ child: Coordinator?)
    /**
     Tells the parent coordinator that given coordinator is done and should be removed from the list of children.
     - Parameters:
        - child: A coordinator.
     */
    func childDidFinish(_ child: Coordinator?)
}

extension ParentCoordinator {
    //MARK: - Coordinator Functions
    /**
     Appends the coordinator to the children array.
     - Parameters:
     - child: The child coordinator to be appended to the list.
     */
    func addChild(_ child: Coordinator?){
        if let _child = child {
            childCoordinators.append(_child)
        }
    }
    
    /**
     Removes the child from children array.
     - Parameters:
     - child: The child coordinator to be removed from the list.
     */
    func childDidFinish(_ child: Coordinator?) {
        for (index, coordinator) in childCoordinators.enumerated() {
            if coordinator === child {
                childCoordinators.remove(at: index)
                break
            }
        }
    }
}

/// All Child coordinators should conform to this protocol
protocol ChildCoordinator: Coordinator {
    var parentCoordinator: ParentCoordinator? { get set }  // weak in implementation
      func coordinatorDidFinish()
}
