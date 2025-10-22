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
    
    
     func showToast(_ msg: String) {
          let alert = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
          present(alert, animated: true)
          DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak alert] in alert?.dismiss(animated: true) }
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


import UIKit

extension UIViewController {

    /// Call this in `viewWillAppear` (and remove in `viewWillDisappear`)
    /// to automatically shift the view up when the keyboard shows.
    func enableKeyboardAvoidance() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    /// Remove observers when you no longer need them
    func disableKeyboardAvoidance() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    // MARK: - Private handlers

    @objc private func handleKeyboardWillShow(_ notification: Notification) {
        guard
            let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else { return }

        // Move view up smoothly (you can tweak the divisor)
        UIView.animate(withDuration: duration) {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardFrame.height / 2.5
            }
        }
    }

    @objc private func handleKeyboardWillHide(_ notification: Notification) {
        guard
            let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else { return }

        UIView.animate(withDuration: duration) {
            self.view.frame.origin.y = 0
        }
    }
}
