//
//  ForgotPasswordView.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 9/27/25.
//

import UIKit
import Combine

class ForgetPasswordEmailViewController: UIViewController {
    
    let customEmailTextField = CustomTextField(placeholder: "Type your email here",topLabelText: "Email",)
    
    
    let sendButton:Custom_Login_Button  = .init(backgroundColor: .electricPurple, title: "Send Reset Link",cornerRadius: 22.5)
    
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
        label.text = "Reset Password"
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
        addDoneButtonOnKeyboard(for:  [customEmailTextField.textField])
        self.view.addSubview(textfieldStackView)
        
        self.textfieldStackView.addArrangedSubview(customEmailTextField)
      
        self.textfieldStackView.addArrangedSubview(sendButton)
        self.textfieldStackView.addArrangedSubview(errorLabel)
      
        
        
        
       
       
        NSLayoutConstraint.activate([
            textfieldStackView.topAnchor.constraint(equalTo: label1.bottomAnchor,constant: 36),
            textfieldStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 24),
            textfieldStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -24),
          
            sendButton.heightAnchor.constraint(equalToConstant: 45),
            
            
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
   
    
    @objc func sendButtonTapped() {
   
       
                viewModel.sendPasswordReset()
               
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
        NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: customEmailTextField.textField)
                .compactMap { ($0.object as? UITextField)?.text }
                .assign(to: \.email, on: viewModel)
                .store(in: &cancellables)
            
            // ViewModel → View
        viewModel.$email
                .receive(on: RunLoop.main)
                .map { Optional($0) }
                .assign(to: \.text, on: customEmailTextField.textField)
                .store(in: &cancellables)
     
        }
    
    private func bindButtons() {
        sendButton.addTarget(nil, action: #selector(sendButtonTapped), for: .touchUpInside)
       
    
    }
    
    
}

#Preview {
    LoginViewController(viewModel: .init())
}
