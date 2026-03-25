//
//  MainCoordinator.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 10/1/25.
//

import UIKit

class MainViewController: UIViewController {
    
    
    
    let viewModel:MainCoordinatorViewModel
    
    
    init(viewModel: MainCoordinatorViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.view.backgroundColor = .red
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target:self, action: #selector(tap)))
       
        
    }
    @objc func tap(){
        Task{
            do{
                print("Logout")
                try await    AuthService.shared.logout()
                print("loged out")
            }catch{
                
            }
        }
    }
    
}
