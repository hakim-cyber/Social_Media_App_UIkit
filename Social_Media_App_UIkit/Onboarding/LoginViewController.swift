//
//  LoginViewController.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 9/23/25.
//

import UIKit
import Combine

class LoginViewController: UIViewController {
    
    let customEmailTextField = CustomTextField(placeholder: "Type your email here",topLabelText: "Email",)
    let customPasswordTextField = CustomTextField(placeholder: "Type your password here",topLabelText: "Password",isSecure: true)
    
    let loginButton:Custom_Login_Button  = .init(backgroundColor: .electricPurple, title: "Login",cornerRadius: 22.5)
    
    var textfieldStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 16
        return stackView
    }()
    
    var forgotPasswordButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Forgot password?", for: .normal)
       
        button.setTitleColor(.electricPurple, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12, weight: .bold)
        button.contentHorizontalAlignment = .trailing
        return button
    }()
    
    let label1: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Login Now To Your Account."
        label.textColor = .label
        label.font = .systemFont(ofSize: 20, weight: .medium)
        return label
    }()
    let label2: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Discover new connections, express yourself, grow your Aura"
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 11, weight: .medium)
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
    var signUpButton: UIButton = {
        let button = UIButton()
        let text = "Don't have and account? *Sign Up*"
        let attributedText = NSAttributedString( text.makeAttributedString(mainColor: .secondaryLabel))
        
      
        button.translatesAutoresizingMaskIntoConstraints = false
     
        button.setAttributedTitle(attributedText, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        button.contentHorizontalAlignment = .trailing
        return button
    }()
    
    var viewModel = LoginViewModel()
    private var cancellables = Set<AnyCancellable>()
    
   
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewDidLoad() {
   
        super.viewDidLoad()
        
        self.view.backgroundColor = .systemBackground
        bindTextfields()
        setLabels()
        setTextFields()
        
        setCustomSignInButtons()
        
        bindButtons()
        bindError()
    }
    func setTextFields() {
        self.view.addSubview(textfieldStackView)
        
        self.textfieldStackView.addArrangedSubview(customEmailTextField)
        self.textfieldStackView.addArrangedSubview(customPasswordTextField)
        self.textfieldStackView.addArrangedSubview(loginButton)
        self.textfieldStackView.addArrangedSubview(errorLabel)
        self.textfieldStackView.addArrangedSubview(forgotPasswordButton)
        
        
        label3.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(label3)
        
       
        NSLayoutConstraint.activate([
            textfieldStackView.topAnchor.constraint(equalTo: labelsStackView.bottomAnchor,constant: 36),
            textfieldStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 24),
            textfieldStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -24),
          
            loginButton.heightAnchor.constraint(equalToConstant: 45),
            
           
            
            label3.topAnchor.constraint(equalTo: textfieldStackView.bottomAnchor, constant: 36),
            
            label3.leadingAnchor.constraint(equalTo: textfieldStackView.leadingAnchor),
            label3.trailingAnchor.constraint(equalTo: textfieldStackView.trailingAnchor),
          
            label3.heightAnchor.constraint(equalToConstant: 20)
            
        ])
    }
    func setLabels() {
        
        self.view.addSubview(labelsStackView)
        
        self.labelsStackView.addArrangedSubview(label1)
        self.labelsStackView.addArrangedSubview(label2)
        
        
       
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
    
        self.view.addSubview(signUpButton)
       
        NSLayoutConstraint.activate([
            customSignStackView.topAnchor.constraint(equalTo: label3.bottomAnchor,constant: 36),
            customSignStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 24),
            customSignStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -24),
          
            appleSignInButton.heightAnchor.constraint(equalToConstant: 45),
         
            googleSignInButton.heightAnchor.constraint(equalToConstant: 45),
           
            signUpButton.topAnchor.constraint(equalTo: customSignStackView.bottomAnchor, constant: 36),
            signUpButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    
    
    @objc func loginButtonTapped() {
        viewModel.login()
        print("Login")
    }
    @objc func forgotPasswordsButtonTapped() {
        viewModel.forgotPassword()
        print("Forgot password")
    }
    func signInWithApple(){
        viewModel.signInWithApple()
        print("Apple")
    }
    
    func signInWithGoogle(){
        viewModel.signInWithGoogle()
        print("Google")
    }
  @objc  func signUpButtonTapped(){
        viewModel.signUp()
        print("Sign UP")
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
        }
    
    private func bindButtons() {
        loginButton.addTarget(nil, action: #selector(loginButtonTapped), for: .touchUpInside)
        forgotPasswordButton.addTarget(nil, action: #selector(forgotPasswordsButtonTapped), for: .touchUpInside)
        appleSignInButton.tapAction = { [weak self] in
            self?.signInWithApple()
           
        }
        googleSignInButton.tapAction = { [weak self] in
            self?.signInWithGoogle()
           
        }
        signUpButton.addTarget(nil, action: #selector(signUpButtonTapped), for: .touchUpInside)
    }
    
    
}

#Preview {
    LoginViewController()
}
