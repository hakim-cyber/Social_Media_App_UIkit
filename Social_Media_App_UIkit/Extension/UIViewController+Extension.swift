//
//  UIViewController+Extension.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 9/25/25.
//

import UIKit

fileprivate var loadingContainerView:UIView!

extension UIViewController{
    func showLoadingView(){
        loadingContainerView = UIView(frame: view.bounds)
        view.addSubview(loadingContainerView)
        
        loadingContainerView.backgroundColor = .systemBackground
        loadingContainerView.alpha = 0
        
        UIView.animate(withDuration: 0.25) {
            loadingContainerView.alpha = 0.8
        }
        let activityIndicator = UIActivityIndicatorView(style: .large)
        
        loadingContainerView.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            activityIndicator.centerYAnchor.constraint(equalTo: loadingContainerView.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: loadingContainerView.centerXAnchor)
        ])
        activityIndicator.startAnimating()
        // Disable interaction for underlying views
          view.isUserInteractionEnabled = false
    }
    func dismissLoadingView(){
        DispatchQueue.main.async{
            self.view.isUserInteractionEnabled = true
            if loadingContainerView != nil{
                loadingContainerView.removeFromSuperview()
                loadingContainerView = nil
            }
        }
    }
    func createDismissKeyboardTapGesture(){
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        view.addGestureRecognizer(tap)
    }
    
    
    
   
        /// Adds a "Done" button to the keyboard for the provided text inputs
        func addDoneButtonOnKeyboard(for inputs: [UIResponder], title: String = "Done") {
            inputs.forEach { input in
                input.addDoneButton(title: title, target: self, selector: #selector(dismissKeyboard))
            }
        }
        
        @objc func dismissKeyboard() {
            view.endEditing(true)
        }
    
    
}
