//
//  ProfileViewController.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 12/20/25.
//

import UIKit
import Foundation
import Combine


class ProfileViewController: UIViewController {
    
    private var cancellables = Set<AnyCancellable>()
    
    
    let vm:ProfileViewModel
    
    
    
    // Views
    let profileInfoContainerView:UIView = UIView()
    let profileInfoContainerStackView:UIStackView = UIStackView()
    let profileHeaderStackView:UIStackView = UIStackView()
    let profileStatsStackView:UIStackView = UIStackView()
    
    
    let avatarImageView = RoundedImageView(url: nil, isCircular: true)
    let postCountLabel = LabelNumberView(text: "posts", number: 0)
    let followersCountLabel = LabelNumberView(text: "followers", number: 0)
    let followingCountLabel = LabelNumberView(text: "following", number: 0)
    
    let nameLabel:UILabel = UILabel()
    var verifiedImage:UIImageView?
    
    let bioLabel: ExpandableLabel = {
        let l = ExpandableLabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.tokenColor = .electricPurple
        l.collapsedNumberOfLines = 2
        l.font = .systemFont(ofSize:15)
        l.textColor = .label
        return l
    }()
    
    
    init(vm:ProfileViewModel) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //    private func setupNavBar() {
    //        navigationItem.title = "Comments"
    //
    //
    //    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setup()
        
    }
    func setupBioLabel(){
        bioLabel.font = .systemFont(ofSize: 15)
        bioLabel.textAlignment = .left
        bioLabel.translatesAutoresizingMaskIntoConstraints = false
        changeDescriptionAndUsername(text: "Player for Manchester United, currently on loan to Liverpool.")
        
       
       
        profileInfoContainerStackView.addArrangedSubview(bioLabel)
        
        
        NSLayoutConstraint.activate([
            bioLabel.leadingAnchor.constraint(equalTo: profileInfoContainerStackView.leadingAnchor),
            bioLabel.trailingAnchor.constraint(equalTo: profileInfoContainerStackView.trailingAnchor),
            
        ])
        
        
    }
    
    func setupNameLabel(){
        nameLabel.font = .systemFont(ofSize: 19, weight: .bold)
           nameLabel.textColor = .label
           nameLabel.numberOfLines = 1

           // ⭐ Required for dots
           nameLabel.lineBreakMode = .byTruncatingTail

           // ❌ Disable shrinking
           nameLabel.adjustsFontSizeToFitWidth = false
           nameLabel.minimumScaleFactor = 1.0

           nameLabel.text = "Erling Braut Haaland"
           nameLabel.translatesAutoresizingMaskIntoConstraints = false

           profileInfoContainerStackView.addArrangedSubview(nameLabel)

      
//        nameLabel.widthAnchor.constraint(
//            lessThanOrEqualTo: profileInfoContainerView.widthAnchor,
//            multiplier: 0.60
//            
//        ).isActive = true
        
        
        setupVerifiedIMageView()
    }
    private func changeDescriptionAndUsername(text:String) {
        // Match label font size for correct truncation behavior
        let attr = NSAttributedString(
            text.makeAttributedString(
                mainColor: .label,
                secondaryColor: .label,
                secondaryWeight: .heavy,
                size: 12
            )
        )
        bioLabel.attributedText = attr
    }

    func setupVerifiedIMageView(){
        let image = UIImage(systemName: "checkmark.seal.fill")!
        verifiedImage = UIImageView(image: image)
        guard let verifiedImage else{return}
        verifiedImage.tintColor = .electricPurple
        verifiedImage.translatesAutoresizingMaskIntoConstraints = false
         
        self.profileInfoContainerView.addSubview(verifiedImage)
        
        NSLayoutConstraint.activate([
            verifiedImage.topAnchor.constraint(equalTo: nameLabel.topAnchor,constant: 1),
            verifiedImage.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 3),
            verifiedImage.widthAnchor.constraint(equalToConstant: 15),
            verifiedImage.heightAnchor.constraint(equalToConstant: 15)
        ])
       
    }
    func setupAvatarImageView(){
        
        
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        
        profileHeaderStackView.addArrangedSubview(avatarImageView)
        
        NSLayoutConstraint.activate([
            avatarImageView.widthAnchor.constraint(equalToConstant: 80),
            avatarImageView.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
    func setupStatsStackView(){
        let hStack = profileStatsStackView
        hStack.axis = .horizontal
        
        hStack.spacing = 20
        hStack.distribution = .fill
    
        hStack.translatesAutoresizingMaskIntoConstraints = false
        
        hStack.addArrangedSubview(postCountLabel)
        hStack.addArrangedSubview(followersCountLabel)
        hStack.addArrangedSubview(followingCountLabel)
        
        profileHeaderStackView.addArrangedSubview(hStack)
        
        NSLayoutConstraint.activate([

         
          
        ])
    }
    func setupProfileHeaderStackView(){
        let hStack = profileHeaderStackView
        hStack.axis = .horizontal
        hStack.alignment = .center
        hStack.distribution = .equalSpacing
        hStack.translatesAutoresizingMaskIntoConstraints = false
        
        profileInfoContainerStackView.addArrangedSubview(hStack)
        NSLayoutConstraint.activate([
        
            profileHeaderStackView.widthAnchor.constraint(equalTo: profileInfoContainerStackView.widthAnchor)
            
    ])
        
        setupAvatarImageView()
        setupStatsStackView()
        
        // Avatar stays fixed
           avatarImageView.setContentHuggingPriority(.required, for: .horizontal)
           avatarImageView.setContentCompressionResistancePriority(.required, for: .horizontal)

           // Stats does NOT expand
           profileStatsStackView.setContentHuggingPriority(.required, for: .horizontal)
           profileStatsStackView.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
   func setupProfileContainerStackView() {
   
       profileInfoContainerStackView.axis = .vertical
       profileInfoContainerStackView.spacing = 12
       profileInfoContainerStackView.alignment = .leading
       profileInfoContainerStackView.translatesAutoresizingMaskIntoConstraints = false

       profileInfoContainerView.addSubview(profileInfoContainerStackView)

       NSLayoutConstraint.activate([
        profileInfoContainerStackView.topAnchor.constraint(equalTo: profileInfoContainerView.topAnchor, constant: 20),
        profileInfoContainerStackView.leadingAnchor.constraint(equalTo: profileInfoContainerView.leadingAnchor, constant: 20),
        profileInfoContainerStackView.trailingAnchor.constraint(equalTo: profileInfoContainerView.trailingAnchor, constant: -20),
        profileInfoContainerStackView.bottomAnchor.constraint(equalTo: profileInfoContainerView.bottomAnchor, constant: -20)
       ])
       setupProfileHeaderStackView()
       setupNameLabel()
       setupBioLabel()
    }
    func setupBackground() {
        profileInfoContainerView.translatesAutoresizingMaskIntoConstraints = false
        profileInfoContainerView.backgroundColor = .systemBackground
        profileInfoContainerView.layer.cornerRadius = 20
        
        view.backgroundColor = .quaternarySystemFill
        
        self.view.addSubview(profileInfoContainerView)
        
        NSLayoutConstraint.activate([
            profileInfoContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            profileInfoContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            profileInfoContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            
    ])
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
       
    }
    func setup() {
        setupBackground()
        setupProfileContainerStackView()
    }
   
    
    func bindToViewModel() {
       

    }
   
   
    
}

#Preview {
    ProfileViewController(vm: .init(target: .me))
}
