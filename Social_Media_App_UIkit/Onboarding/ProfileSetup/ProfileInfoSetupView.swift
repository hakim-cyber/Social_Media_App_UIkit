//
//  ProfileInfoSetupView.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 9/30/25.
//

import UIKit
import Combine

class ProfileInfoSetupView: UIViewController {
    
    
    let label1: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Info About You"
        label.textColor = .label
        label.font = .systemFont(ofSize:    20, weight: .bold)
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
        usernameField.textField.placeholder = "username"
        usernameField.textField.textColor = .electricPurple
        usernameField.underlineColor = .secondaryLabel
        usernameField.underlineHeight = 2.0
        usernameField.textField.autocorrectionType = .no
        usernameField.textField.autocapitalizationType = .none
        
        let atLabel = UILabel()
        atLabel.text = "@"
        atLabel.font = usernameField.textField.font
        atLabel.textColor = .electricPurple
        
        usernameField.textField.leftView = atLabel
        usernameField.textField.leftViewMode = .always
        
       
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
        let usernameField = InputFieldWithTitleAndCounter(title: "Bio",maxCharacters: 149)
       
    
        usernameField.translatesAutoresizingMaskIntoConstraints = false
      
        return usernameField
    }()
    
    let nextButton:Custom_Login_Button  = .init(backgroundColor: .electricPurple, title: "Next",cornerRadius: 25)
    let underlinedButton = UnderlinedButton(title: "Skip for now", underline: true, underlineColor: .label, textColor: .label, font: .systemFont(ofSize: 16, weight: .bold))
    
    
    let viewModel:OnboardingSetupViewModel
    private var cancellables = Set<AnyCancellable>()
    private var usernameDebounceTimer: Timer?
    
    var userNameIsValid: Bool  = false
    var nameIsValid: Bool  = false
    deinit {
            usernameDebounceTimer?.invalidate()
        }
    
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
        bindError()
    }
    @objc private func usernameEditingChanged(_ textField: UITextField) {
           // Cancel previous timer
           usernameDebounceTimer?.invalidate()

           // Start a new debounce timer (fires once after 0.5s)
           usernameDebounceTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
               guard let self = self else { return }
               self.performUsernameCheck()
           }

           // Ensure timer fires while UI is busy (scrolling, etc.)
           RunLoop.main.add(usernameDebounceTimer!, forMode: .common)
       }
    @objc private func nameEditingChanged(_ textField: UITextField) {
        let name = textField.text ?? ""
        guard  name.isEmpty == false else {
            self.nameTextField.changeUnderlineColor(color: UIColor.systemGray3)
            self.nameIsValid = true
            return
        }
        if validateFullName(name) {
            UIView.animate(withDuration: 0.4){
                // ✅ Valid: underline green
                self.nameTextField.changeUnderlineColor(color: UIColor.systemGreen.withAlphaComponent(0.6))
               
                self.nameIsValid = true
            }
            self.errorLabel.isHidden = true
        } else {
            UIView.animate(withDuration: 0.2){
                // ❌ Invalid: underline red + show error
                self.nameTextField.changeUnderlineColor(color: UIColor.electricPurple)
                
                self.nameIsValid = false
            }
            self.errorLabel.text = "Name must be 2–40 letters, only letters/spaces."
            self.errorLabel.isHidden = false
        }
    }

       private func performUsernameCheck() {
           let raw = userNameTextField.textField.text ?? ""
           let username = raw.replacingOccurrences(of: "@", with: "").lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
           
           self.userNameTextField.textField.text = username
           Task { [weak self] in
               guard let self = self else { return }
               let available = await self.viewModel.checkUsername(userName: username)
               
               print(available)
               // Example UI feedback: underline color
               DispatchQueue.main.async {
                   UIView.animate(withDuration: 0.2){
                       self.userNameTextField.changeUnderlineColor(color: (available ? UIColor.systemGreen.withAlphaComponent(0.6) : UIColor.electricPurple))
                       self.userNameTextField.setNeedsLayout()
                   }
                   self.userNameIsValid = available
               }
           }
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
        userNameTextField.textField.addTarget(self, action: #selector(usernameEditingChanged(_:)), for: .editingChanged)
        nameTextField.textField.addTarget(self, action: #selector(nameEditingChanged(_:)), for: .editingChanged)
        createDismissKeyboardTapGesture()
        addDoneButtonOnKeyboard(for:  [userNameTextField.textField,nameTextField.textField,bioTextField.textView])
        self.view.addSubview(userNameTextField)
        self.view.addSubview(nameTextField)
        self.view.addSubview(bioTextField)
        
        self.view.addSubview(errorLabel)
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
            bioTextField.heightAnchor.constraint(lessThanOrEqualTo: view.heightAnchor, multiplier: 0.3),
           
            errorLabel.topAnchor.constraint(equalTo: bioTextField.bottomAnchor,constant: 24),
            errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
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
    private func bindError() {
        viewModel.$error
            .receive(on: RunLoop.main)
           
            .sink { [weak self] error in
                guard let self = self else { return }
                if let error{
                  
                        self.errorLabel.text = error
                        self.errorLabel.isHidden = false
                    
                }else{
                   
                        self.errorLabel.text = ""
                        self.errorLabel.isHidden = true
                    
                }
                
            }
            .store(in: &cancellables)
    }
    
    @objc func handleNext(){
        if self.userNameIsValid && nameIsValid{
            print("next")
            self.viewModel.setInfo(userName: userNameTextField.textField.text ?? "", name: nameTextField.textField.text ?? "", bio: bioTextField.textView.text ?? "")
        }
        
    }
    @objc func handleSkip(){
        if self.userNameIsValid{
            print("skip")
            self.viewModel.setInfo(userName: userNameTextField.textField.text ?? "", name: "", bio: "")
        }
    }
    
    private func validateFullName(_ name: String) -> Bool {
            let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)

            guard trimmed.count >= 2 else { return false }
            guard trimmed.count <= 40 else { return false }
            
            // Allow only letters and spaces
            let pattern = "^[a-zA-Z ]+$"
            let regex = try? NSRegularExpression(pattern: pattern)
            let range = NSRange(trimmed.startIndex..., in: trimmed)
            
            return regex?.firstMatch(in: trimmed, options: [], range: range) != nil
        }
}

#Preview{
    ProfileInfoSetupView(viewModel: OnboardingSetupViewModel())
}

