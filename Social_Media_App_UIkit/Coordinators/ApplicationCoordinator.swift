//
//  ApplicationCoordinator.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 9/20/25.
//

import UIKit


class ApplicationCoordinator:ParentCoordinator{
    var childCoordinators: [Coordinator] = []
    
    var navigationController: UINavigationController
   
    init(navigationController:UINavigationController){
        self.navigationController = navigationController
    }
   
    
    func start(animated: Bool){
//        if AuthService.shared.isLoggedIn {
//                  showMainFlow()
//              } else {
//                  showAuthFlow()
//              }
       
        
    }
  
    
}

