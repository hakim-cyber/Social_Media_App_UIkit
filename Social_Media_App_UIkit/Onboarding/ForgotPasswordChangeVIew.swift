//
//  ForgotPasswordChangeVIew.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 9/27/25.
//

import UIKit
import Combine


class ForgotPasswordChangeVIew: UIViewController {
    
    let customPasswordTextField = CustomTextField(placeholder: "New password here",topLabelText: "New Password",isSecure: true)
    let confirmPasswordTextField = CustomTextField(placeholder: "Confirm your new password here",topLabelText: "Confirm Password",isSecure: true)
    
    
    let changeButton:Custom_Login_Button  = .init(backgroundColor: .electricPurple, title: "Change Password",cornerRadius: 22.5)
    
    var textfieldStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 16
        return stackView
    }()
    
   
    let label1: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Change Password"
        label.textColor = .label
        label.font = .systemFont(ofSize:    18, weight: .medium)
        return label
    }()
    
    
    let errorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Something went wrong. Please try again later."
        label.textColor = .electricPurple
        label.numberOfLines = 0
        label.textAlignment = .center
        label.isHidden = true
        label.font = .systemFont(ofSize: 11, weight: .regular)
        return label
    }()
  
    let viewModel:ForgotPasswordViewModel
    private var cancellables = Set<AnyCancellable>()
    init(viewModel: ForgotPasswordViewModel) {
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
        
        self.view.backgroundColor = .systemBackground
       
        setLabels()
        setTextFields()
     
        createDismissKeyboardTapGesture()
        bindTextfields()
        bindButtons()
        bindError()
        bindLoading()
    }
    func setTextFields() {
        addDoneButtonOnKeyboard(for:  [customPasswordTextField.textField,confirmPasswordTextField.textField])
        self.view.addSubview(textfieldStackView)
        
    
        self.textfieldStackView.addArrangedSubview(customPasswordTextField)
        self.textfieldStackView.addArrangedSubview(confirmPasswordTextField)
        self.textfieldStackView.addArrangedSubview(changeButton)
        self.textfieldStackView.addArrangedSubview(errorLabel)
        
        
       
       
        NSLayoutConstraint.activate([
            textfieldStackView.topAnchor.constraint(equalTo: label1.bottomAnchor,constant: 36),
            textfieldStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 24),
            textfieldStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -24),
          
            changeButton.heightAnchor.constraint(equalToConstant: 45),
            
            
        ])
    }
    func setLabels() {
        
    
        
        self.view.addSubview(label1)
        
        
        
       
        NSLayoutConstraint.activate([
            label1.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 24),
            label1.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,constant: 24),
            label1.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -view.frame.width * 0.3)
        ])
    }
   
    
    func showConfirmMailAlert(){
        let alert = UIAlertController(
                                title: "Changed Your Password",
                                message:"You can now enter with new password.",
                                preferredStyle: .alert
                            )
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            self.dismiss(animated: true)
        }))
                            self.present(alert, animated: true)
    }
    
    
    
    @objc func changeButtonTapped() {
   
       
        viewModel.changePasswordToNewOne {[weak self] in
                    self?.showConfirmMailAlert()
                }
               
    }
   
  
 
  
        private func bindError() {
            viewModel.$loginError
                .receive(on: RunLoop.main)
               
                .sink { [weak self] error in
                    guard let self = self else { return }
                    if let error{
                      
                            self.errorLabel.text = error.localizedDescription
                            self.errorLabel.isHidden = false
                        
                    }else{
                       
                            self.errorLabel.text = ""
                            self.errorLabel.isHidden = true
                        
                    }
                    
                }
                .store(in: &cancellables)
        }
    private func bindLoading() {
        viewModel.$isLoading
            .receive(on: RunLoop.main)
            .sink { [weak self] isLoading in
                guard let self = self else { return }
                
                if isLoading {
                    self.showLoadingView()
                  
                } else {
                    self.dismissLoadingView()
                  
                }
            }
            .store(in: &cancellables)
    }
    
    private func bindTextfields() {
          
        // View → ViewModel
    NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: customPasswordTextField.textField)
            .compactMap { ($0.object as? UITextField)?.text }
            .assign(to: \.newPassword, on: viewModel)
            .store(in: &cancellables)
        
        // ViewModel → View
    viewModel.$newPassword
            .receive(on: RunLoop.main)
            .map { Optional($0) }
            .assign(to: \.text, on: customPasswordTextField.textField)
            .store(in: &cancellables)
        // View → ViewModel
    NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: confirmPasswordTextField.textField)
            .compactMap { ($0.object as? UITextField)?.text }
            .assign(to: \.confirmPassword, on: viewModel)
            .store(in: &cancellables)
        
        // ViewModel → View
    viewModel.$confirmPassword
            .receive(on: RunLoop.main)
            .map { Optional($0) }
            .assign(to: \.text, on: confirmPasswordTextField.textField)
            .store(in: &cancellables)
     
        }
    
    private func bindButtons() {
        changeButton.addTarget(nil, action: #selector(changeButtonTapped), for: .touchUpInside)
       
    
    }
    
    
}

#Preview {
    LoginViewController(viewModel: .init())
}
