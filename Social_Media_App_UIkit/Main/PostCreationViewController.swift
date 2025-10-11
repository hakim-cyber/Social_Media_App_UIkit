//
//  PostCreationViewController.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 10/5/25.
//

import UIKit


class PostCreationViewController: UIViewController {
  
    var selectImageView:PostImageSelectView = .init()
    
    let captionTextField:InputFieldWithTitleAndCounter = {
        let field = InputFieldWithTitleAndCounter(title: "Caption",maxCharacters: 249)
       
    
        field.translatesAutoresizingMaskIntoConstraints = false
      
        return field
    }()
    
    let locationButton:LocationPickerButton = .init()
    
    
    var selectedImage:UIImage?
    
    init() {
       
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        enableKeyboardAvoidance()
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        disableKeyboardAvoidance()
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.view.backgroundColor = .systemBackground
     
        setupNavBar()
       
       
        setImageSelectView()
        setTextField()
        setLocationButton()
     
    }
   
    
    private func setupNavBar() {
        // Cancel button
        let cancelButton = UIBarButtonItem(
            title: "Cancel",
            style: .plain,
            target: self,
            action: #selector(cancelTapped)
        )

        // Post button
        let postButton = UIBarButtonItem(
            title: "Post",
            style: .prominent,
            target: self,
            action: #selector(postTapped)
        )

        // Apply electric purple tint
        let electricPurple = UIColor.electricPurple
        cancelButton.tintColor = electricPurple
        postButton.tintColor = electricPurple

        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.rightBarButtonItem = postButton
    }

    @objc private func cancelTapped() {
        Task{
         try? await   AuthService.shared.logout()
        }
        dismiss(animated: true)
    }

    @objc private func postTapped() {
        
        if let image = self.selectedImage{
            // Handle post logic here
            print("Post tapped with caption: \(captionTextField.textView.text ?? "") location: \(locationButton.locationText ?? "none")")
            let (caption,location) = (captionTextField.textView.text,locationButton.locationText)
            let sv = PostService()
            Task{
                self.showLoadingView()
                do{
                    try await   sv.createPost(caption: caption, image: image , location: location)
                    self.dismissLoadingView()
                }catch{
                    print(error)
                    print(error.localizedDescription)
                    self.dismissLoadingView()
                }
            }
        }
    }
    func setLocationButton(){
        self.view.addSubview(locationButton)
        // Open picker
           locationButton.onTap = { [weak self] in
               self?.presentLocationPicker()
           }
        locationButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            locationButton.topAnchor.constraint(equalTo: captionTextField.bottomAnchor, constant: 12),
            locationButton.leadingAnchor.constraint(equalTo: selectImageView.leadingAnchor),  locationButton.trailingAnchor.constraint(equalTo: selectImageView.trailingAnchor),
            
        ])
    }
    
    private func presentLocationPicker() {
        let picker = LocationTextPickerViewController()
        picker.onSelect = { [weak self] locationString in
            // Update UI + VM
            self?.locationButton.locationText = locationString
            
            // self?.viewModel.location = locationString
        }
        // Present modally with a nav (so there’s a search bar title area)
        let nav = UINavigationController(rootViewController: picker)
        present(nav, animated: true)
    }
    
    func setTextField(){
        addDoneButtonOnKeyboard(for:  [captionTextField.textView])
        self.createDismissKeyboardTapGesture()
        view.addSubview(captionTextField)
        NSLayoutConstraint.activate([
            
                       captionTextField.leadingAnchor.constraint(equalTo:  selectImageView.leadingAnchor),
                       captionTextField.topAnchor.constraint(equalTo: selectImageView.bottomAnchor,constant: 24),
                       captionTextField.trailingAnchor.constraint(equalTo: selectImageView.trailingAnchor),
                       captionTextField.heightAnchor.constraint(lessThanOrEqualTo: view.heightAnchor, multiplier: 0.3),
                     
                       ])
    }
    
    func setImageSelectView(){
        selectImageView.onTap = {[weak self] in
            print("on tap closure")
            self?.presentImagePicker()
        }
        self.view.addSubview(selectImageView)
        NSLayoutConstraint.activate([
            selectImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,constant: 24),
           
            selectImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant:  16),
            selectImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant:  -16),
                   // 👇 Square
            selectImageView.heightAnchor.constraint(equalTo: selectImageView.widthAnchor ,multiplier: AppConstants.Media.defaultPostCropRatio.height),
          
               
        ])
    }
  
    
    func presentImagePicker(){
        ImagePickerCropper.shared.present(from: self, aspectRatio: AppConstants.Media.defaultPostCropRatio) { [weak self] image in
            guard let self else{return}
            self.selectedImage = image
            self.selectImageView.setImage(image: selectedImage)
        }
    }
    
}

#Preview(){
    UINavigationController(rootViewController: PostCreationViewController())
}


extension PostCreationViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
       
        if let editedImage = info[.editedImage] as? UIImage {
            self.selectedImage = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            self.selectedImage = originalImage
        }
       
        selectImageView.setImage(image: selectedImage)
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
