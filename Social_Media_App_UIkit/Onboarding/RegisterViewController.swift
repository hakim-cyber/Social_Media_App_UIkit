//
//  RegisterViewController.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 9/26/25.
//

import UIKit
import Combine
import AuthenticationServices

class RegisterViewController: UIViewController {
    
    let customEmailTextField = CustomTextField(placeholder: "Type your email here",topLabelText: "Email",)
    let customPasswordTextField = CustomTextField(placeholder: "Type your password here",topLabelText: "Password",isSecure: true)
    let confirmPasswordTextField = CustomTextField(placeholder: "Confirm your password here",topLabelText: "Confirm Password",isSecure: true)
    
    let registerButton:Custom_Login_Button  = .init(backgroundColor: .electricPurple, title: "Create Account",cornerRadius: 22.5)
    
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
        label.text = "Create Account"
        label.textColor = .label
        label.font = .systemFont(ofSize:    18, weight: .medium)
        return label
    }()
    
    let labelsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 8
        return stackView
    }()
    let label3 = DividerWithText(text: "OR")
    
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
    let googleSignInButton:CustomSignInButton  = .init(backgroundColor: .secondarySystemBackground, title: "Sign in with Google",image: UIImage.googleLogo, cornerRadius: 22.5)
    let appleSignInButton:CustomSignInButton  = .init(backgroundColor: .secondarySystemBackground, title: "Continue with Apple",image: UIImage.appleLogo,cornerRadius: 22.5)
    
    let customSignStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 8
        return stackView
    }()
    
    
      let viewModel:RegisterViewModel
      private var cancellables = Set<AnyCancellable>()
      init(viewModel: RegisterViewModel) {
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
        
        setCustomSignInButtons()
        
        createDismissKeyboardTapGesture()
        bindTextfields()
        bindButtons()
        bindError()
        bindLoading()
    }
    func setTextFields() {
        addDoneButtonOnKeyboard(for:  [customEmailTextField.textField,customPasswordTextField.textField,confirmPasswordTextField.textField])
        self.view.addSubview(textfieldStackView)
        
        self.textfieldStackView.addArrangedSubview(customEmailTextField)
        self.textfieldStackView.addArrangedSubview(customPasswordTextField)
        self.textfieldStackView.addArrangedSubview(confirmPasswordTextField)
        self.textfieldStackView.addArrangedSubview(registerButton)
        self.textfieldStackView.addArrangedSubview(errorLabel)
      
        
        
        
        label3.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(label3)
        
       
        NSLayoutConstraint.activate([
            textfieldStackView.topAnchor.constraint(equalTo: labelsStackView.bottomAnchor,constant: 36),
            textfieldStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 24),
            textfieldStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -24),
          
            registerButton.heightAnchor.constraint(equalToConstant: 45),
            
           
            
            label3.topAnchor.constraint(equalTo: textfieldStackView.bottomAnchor, constant: 36),
            
            label3.leadingAnchor.constraint(equalTo: textfieldStackView.leadingAnchor),
            label3.trailingAnchor.constraint(equalTo: textfieldStackView.trailingAnchor),
          
            label3.heightAnchor.constraint(equalToConstant: 20)
            
        ])
    }
    func setLabels() {
        
        self.view.addSubview(labelsStackView)
        
        self.labelsStackView.addArrangedSubview(label1)
        
        
        
       
        NSLayoutConstraint.activate([
            labelsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 24),
            labelsStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,constant: 24),
            labelsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -view.frame.width * 0.3)
        ])
    }
    
    func setCustomSignInButtons() {
        self.view.addSubview(customSignStackView)
        
        self.customSignStackView.addArrangedSubview(appleSignInButton)
        self.customSignStackView.addArrangedSubview(googleSignInButton)
    
      
       
        NSLayoutConstraint.activate([
            customSignStackView.topAnchor.constraint(equalTo: label3.bottomAnchor,constant: 36),
            customSignStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 24),
            customSignStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -24),
          
            appleSignInButton.heightAnchor.constraint(equalToConstant: 45),
         
            googleSignInButton.heightAnchor.constraint(equalToConstant: 45),
           
         
        ])
    }
    
    @objc func registerButtonTapped() {
   
                
                viewModel.signUp()
               
    }
   
    func signInWithApple(){
        viewModel.signInWithApple(presentationContextProvider: self)
        print("Apple")
    }
    
    func signInWithGoogle(){
        viewModel.signInWithGoogle(viewController: self)
        print("Google")
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
        
        // View → ViewModel
    NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: customPasswordTextField.textField)
            .compactMap { ($0.object as? UITextField)?.text }
            .assign(to: \.password, on: viewModel)
            .store(in: &cancellables)
        
        // ViewModel → View
    viewModel.$password
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
        registerButton.addTarget(nil, action: #selector(registerButtonTapped), for: .touchUpInside)
       
        appleSignInButton.tapAction = { [weak self] in
            self?.signInWithApple()
           
        }
        googleSignInButton.tapAction = { [weak self] in
            self?.signInWithGoogle()
           
        }
    
    }
    
    
}

#Preview {
    LoginViewController(viewModel: .init())
}



// MARK: - Confirming to ASAuthorizationControllerPresentationContextProviding

extension RegisterViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    
}
