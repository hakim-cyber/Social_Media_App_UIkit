//
//  ProfileInfoSetupView.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 9/30/25.
//

import UIKit

class ProfileInfoSetupView: UIViewController {
    
    
    let label1: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Info About You"
        label.textColor = .label
        label.font = .systemFont(ofSize:    25, weight: .bold)
        return label
    }()
    let label2: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Tell us about yourself"
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize:    15, weight: .medium)
        return label
    }()
    let userNameTextField:UnderlinedTextFieldView = {
        let usernameField = UnderlinedTextFieldView()
        usernameField.translatesAutoresizingMaskIntoConstraints = false
        usernameField.titleLabel.text = "Username"
        usernameField.textField.placeholder = "Enter username"
        usernameField.textField.textColor = .electricPurple
        usernameField.underlineColor = .secondaryLabel
        usernameField.underlineHeight = 2.0
      
        
        usernameField.paddingBetween = 12.0
        return usernameField
    }()
    let nameTextField:UnderlinedTextFieldView = {
        let usernameField = UnderlinedTextFieldView()
        usernameField.translatesAutoresizingMaskIntoConstraints = false
        usernameField.titleLabel.text = "Full Name"
        usernameField.textField.placeholder = "Enter your name"
        usernameField.textField.textColor = .electricPurple
        usernameField.underlineColor = .secondaryLabel
        usernameField.underlineHeight = 2.0
      
        
        usernameField.paddingBetween = 12.0
        return usernameField
    }()
    let bioTextField:InputFieldWithTitleAndCounter = {
        let usernameField = InputFieldWithTitleAndCounter(title: "Bio",maxCharacters: 150)
       
        usernameField.translatesAutoresizingMaskIntoConstraints = false
      
        return usernameField
    }()
    
    let nextButton:Custom_Login_Button  = .init(backgroundColor: .electricPurple, title: "Next",cornerRadius: 25)
    let underlinedButton = UnderlinedButton(title: "Skip for now", underline: true, underlineColor: .label, textColor: .label, font: .systemFont(ofSize: 16, weight: .bold))
    
    
    let viewModel:OnboardingSetupViewModel
    
    
    init(viewModel: OnboardingSetupViewModel) {
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
        setTextfields()
        setButtons()
        
    }
    func setButtons(){
        
        
        self.view.addSubview(underlinedButton)
        self.view.addSubview(nextButton)
        
        underlinedButton.addTarget(self, action: #selector(handleSkip), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(handleNext), for: .touchUpInside)
        NSLayoutConstraint.activate([
            
            underlinedButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor,constant: -24),
            underlinedButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            
            nextButton.bottomAnchor.constraint(equalTo: self.underlinedButton.topAnchor,constant: -24),
            nextButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            nextButton.widthAnchor.constraint(equalTo:self.view.widthAnchor,multiplier: 0.8),
            nextButton.heightAnchor.constraint(equalToConstant: 50),
            
        ])
        
    }
    func setTextfields(){
        self.view.addSubview(userNameTextField)
        self.view.addSubview(nameTextField)
        self.view.addSubview(bioTextField)
        
        NSLayoutConstraint.activate([
            userNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 24),
            userNameTextField.topAnchor.constraint(equalTo: label2.bottomAnchor,constant: 24),
            userNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -24),
            
            
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 24),
            nameTextField.topAnchor.constraint(equalTo: userNameTextField.bottomAnchor,constant: 24),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -24),
            
            bioTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 24),
            bioTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor,constant: 24),
            bioTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -24),
          
           
            
        ])
    }
    func setLabels() {
        self.view.addSubview(label1)
        self.view.addSubview(label2)
        
        
        NSLayoutConstraint.activate([
            label1.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 24),
            label1.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,constant: 24),
            label1.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -view.frame.width * 0.3),
            
            label2.leadingAnchor.constraint(equalTo: label1.leadingAnchor),
            label2.topAnchor.constraint(equalTo: label1.bottomAnchor,constant: 24),
            
        ])
    }
    
    @objc func handleNext(){
        print("next")
        
    }
    @objc func handleSkip(){
        print("skip")
        
    }
}

#Preview{
    ProfileInfoSetupView(viewModel: OnboardingSetupViewModel())
}
