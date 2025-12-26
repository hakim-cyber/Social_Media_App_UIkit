//
//  EditProfileView.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 12/26/25.
//

import UIKit
import Combine
import TOCropViewController

class ProfileEditViewController: UIViewController {

    let profileImageView  = ProfileImageView(borderWidth: 1.0, imageColor: .gray,borderColor:.label, showPlus:true, plusBackground: .systemBlue,plusColor: .label)
    
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
    
    private let outerScroll = UIScrollView()
    private let contentView = UIView()
    

    private let stackView: UIStackView = {
        let s = UIStackView()
        s.translatesAutoresizingMaskIntoConstraints = false
        s.axis = .vertical
        s.alignment = .center
        s.spacing = 12
      
        return s
    }()
    
    let viewModel:EditProfileViewModel
    
    var selectedImage:UIImage?
    private var cancellables = Set<AnyCancellable>()
    private var usernameDebounceTimer: Timer?
    
    var userNameIsValid: Bool  = true
    var nameIsValid: Bool  = true
    
    init(viewModel: EditProfileViewModel) {
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
      
        setupNavigationBar()
        setViews()
        bindError()
        bindLoading()
        setInitialValues()
        
    }
    func setInitialValues(){
        self.nameTextField.textField.text = self.viewModel.name
        self.userNameTextField.textField.text = self.viewModel.userName
        self.bioTextField.textView.text = self.viewModel.bio
        self.profileImageView.setImage(self.viewModel.image, animated: true)
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
    func setViews(){
        self.view.addSubview(outerScroll)
        self.outerScroll.addSubview(contentView)
        self.contentView.addSubview(stackView)
        outerScroll.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            outerScroll.topAnchor.constraint(equalTo: view.topAnchor),
            outerScroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            outerScroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            outerScroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            
            // contentView defines scroll content size (vertical)
               contentView.topAnchor.constraint(equalTo: outerScroll.contentLayoutGuide.topAnchor),
               contentView.bottomAnchor.constraint(equalTo: outerScroll.contentLayoutGuide.bottomAnchor),

               // ✅ THIS is the key fix: pin contentView horizontally to the *frameLayoutGuide*
               contentView.leadingAnchor.constraint(equalTo: outerScroll.leadingAnchor),
               contentView.trailingAnchor.constraint(equalTo: outerScroll.trailingAnchor),
            
            contentView.widthAnchor.constraint(equalTo: outerScroll.frameLayoutGuide.widthAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            ])
        setAvatarImageView()
        setupTextFields()
    }
    func setupTextFields(){
        userNameTextField.textField.addTarget(self, action: #selector(usernameEditingChanged(_:)), for: .editingChanged)
        nameTextField.textField.addTarget(self, action: #selector(nameEditingChanged(_:)), for: .editingChanged)
        createDismissKeyboardTapGesture()
        addDoneButtonOnKeyboard(for:  [userNameTextField.textField,nameTextField.textField,bioTextField.textView])
        self.stackView.addArrangedSubview(userNameTextField)
        self.stackView.addArrangedSubview(nameTextField)
        self.stackView.addArrangedSubview(bioTextField)
        self.stackView.addArrangedSubview(errorLabel)
        
        NSLayoutConstraint.activate([
            userNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 24),
           
            userNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -24),
            
            
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 24),
            
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -24),
            
            bioTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 24),
            bioTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -24),
            bioTextField.heightAnchor.constraint(lessThanOrEqualTo: view.heightAnchor, multiplier: 0.2),
           
            errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    func setAvatarImageView(){
        self.stackView.addArrangedSubview(profileImageView)
        
        profileImageView.onTap = {[weak self] in
            self?.presentImagePicker()
        }
        
        
        NSLayoutConstraint.activate([
           
           
     
            profileImageView.heightAnchor.constraint(equalToConstant: 120),
            profileImageView.widthAnchor.constraint(equalToConstant: 120),
            
        ])
    }
    func setupNavigationBar(){
      
           
            // Post button
            let saveButton = UIBarButtonItem(
                title: "Save",
                style: .prominent,
                target: self,
                action: #selector(handleSave)
            )

            // Apply electric purple tint
            let electricPurple = UIColor.electricPurple
           
        saveButton.tintColor = electricPurple

           
            navigationItem.rightBarButtonItem = saveButton
        
        navigationItem.title = "Edit Profile"
        

    }
    @objc func handleSave(){
        if self.userNameIsValid && nameIsValid{
            self.viewModel.saveUserProfile(image: selectedImage, userName:  userNameTextField.textField.text ?? "", name: nameTextField.textField.text ?? "", bio: bioTextField.textView.text ?? "") { completed in
                self.setInitialValues()
            }
        }
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
    private func bindLoading() {
        viewModel.$image
            .receive(on: RunLoop.main)
            .sink { [weak self] image in
                guard let self = self else { return }
                self.profileImageView.setImage(image)
            }
            .store(in: &cancellables)
        viewModel.$loading
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
    private var imagePicker: ImagePickerCropper?
    func presentImagePicker(){
        let picker = ImagePickerCropper()
            self.imagePicker = picker

        picker.presentMenu(
                    from: self,
                    sourceView: profileImageView,
                    aspectRatio: CGSize(width: 1, height: 1),
                    croppingStyle: .circular,
                    allowsDelete: self.selectedImage != nil
                ) {[weak self] result in
            guard let self else{return}
           
           
            switch result {
                      case .picked(let image):
                self.selectedImage = image
                self.profileImageView.setImage(self.selectedImage, animated: true)

                      case .deleted:
                self.selectedImage = nil
                self.profileImageView.setImage(self.selectedImage, animated: true)
                      case .cancelled:
                          break
                      }

                      // release after use
                      self.imagePicker = nil
        }
    }
   
}

#Preview(){
    ProfileImageSelectView(viewModel: OnboardingSetupViewModel(profileService: .init()))
}
