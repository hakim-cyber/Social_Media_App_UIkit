//
//  ProfileImageSelectView.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 9/29/25.
//

import UIKit

class ProfileImageSelectView: UIViewController {
    
    
    let label1: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Pick a profile picture"
        label.textColor = .label
        label.font = .systemFont(ofSize:    20, weight: .bold)
        return label
    }()
    let label2: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Have a favorite selfie? Upload it now."
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize:    15, weight: .medium)
        return label
    }()
    let profileImageView  = ProfileImageView(borderWidth: 3.0, imageColor: .gray,borderColor:.label, showPlus:true, plusBackground: .systemBlue,plusColor: .label)
    
    let nextButton:Custom_Login_Button  = .init(backgroundColor: .electricPurple, title: "Next",cornerRadius: 25)
    let underlinedButton = UnderlinedButton(title: "Skip for now", underline: true, underlineColor: .label, textColor: .label, font: .systemFont(ofSize: 16, weight: .bold))
    
    
    
    let viewModel:OnboardingSetupViewModel
    
    var selectedImage:UIImage?
    
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
        setProfileImageView()
        
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
    @objc func handleNext(){
        print("next")
        viewModel.setProfileImage(selectedImage)
    }
    @objc func handleSkip(){
        print("skip")
        viewModel.setProfileImage(nil)
    }
    func presentImagePicker(){
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    func setProfileImageView() {
        
        self.view.addSubview(profileImageView)
        
        profileImageView.onTap = {[weak self] in
            self?.presentImagePicker()
        }
        
        
        NSLayoutConstraint.activate([
            profileImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            profileImageView.topAnchor.constraint(equalTo: label2.bottomAnchor,constant: 44),
            profileImageView.widthAnchor.constraint(equalTo:self.view.widthAnchor,multiplier: 0.5),
            profileImageView.heightAnchor.constraint(equalTo:self.view.widthAnchor,multiplier: 0.5),
            
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
    
}

#Preview(){
    ProfileImageSelectView(viewModel: OnboardingSetupViewModel(profileService: .init()))
}

extension ProfileImageSelectView:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
       
        if let editedImage = info[.editedImage] as? UIImage {
            self.selectedImage = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            self.selectedImage = originalImage
        }
       
        profileImageView.setImage(selectedImage, animated: true)
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
