//
//  PostCreationViewController.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 10/5/25.
//
import Combine
import UIKit


class PostCreationViewController: UIViewController {
  
    var selectImageView:PostImageSelectView = .init()
    
    let captionTextField:InputFieldWithTitleAndCounter = {
        let field = InputFieldWithTitleAndCounter(title: "Caption",maxCharacters: 249)
       
    
        field.translatesAutoresizingMaskIntoConstraints = false
      
        return field
    }()
    
    let locationButton:LocationPickerButton = .init()
    
    let vm:CreatePostViewModel
    private var imagePicker: ImagePickerCropper?
    
    private var cancellables = Set<AnyCancellable>()
    
    init(vm:CreatePostViewModel) {
        self.vm = vm
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
        bindViewModel()
       
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
            style: .plain,
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
        vm.tappedCancel()
    }

    @objc private func postTapped() {
        Task{
          await  self.vm.createPost(caption: captionTextField.textView.text, location: locationButton.locationText)
        }
       
    }
    func bindViewModel(){
        vm.$isLoading
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
      
        
                vm.$errorMessage
                    .compactMap { $0 }
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] msg in
                        self?.showToast(msg)
                    }
                    .store(in: &cancellables)

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
        let picker = ImagePickerCropper()
               self.imagePicker = picker

        picker.presentMenu(from: self, aspectRatio: AppConstants.Media.defaultPostCropRatio) { [weak self] result in
            guard let self else { return }

                        switch result {
                        case .picked(let image):
                            self.vm.selectedImage = image

                        case .deleted:
                            self.vm.selectedImage = nil

                        case .cancelled:
                            break
                        }

                        // release after use
            self.imagePicker = nil
            self.selectImageView.setImage(image: self.vm.selectedImage)
        }
    }
    
}

#Preview(){
    UINavigationController(rootViewController: PostCreationViewController(vm: CreatePostViewModel()))
}


extension PostCreationViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
       
        if let editedImage = info[.editedImage] as? UIImage {
            self.vm.selectedImage = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            self.vm.selectedImage = originalImage
        }
       
        selectImageView.setImage(image: vm.selectedImage)
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
