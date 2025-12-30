//
//  ProfileHeaderView.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 12/22/25.
//

import UIKit

protocol ProfileHeaderViewDelegate:AnyObject{
     func followButtonTapped()
     func messageButtonTapped()
     func editProfileButtonTapped()
     func shareProfileButtonTapped()
    func didTapFollowerCount()
    func didTapFollowingCount()
}
final class ProfileHeaderView: UIView {

    var isCurrentUser:Bool = false
    weak var delegate:ProfileHeaderViewDelegate?
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
    
    let buttonsStackView:UIStackView = UIStackView()
    
    let button1:CustomStyledButton = .init(style: .primary, text: "Follow")
    let button2:CustomStyledButton = .init(style: .secondary, text: "Message")
    
     init(frame: CGRect = .zero,isCurrentUser:Bool) {
        self.isCurrentUser = isCurrentUser
           super.init(frame: frame)
          setup()
       }

       required init?(coder: NSCoder) { fatalError() }
    
    func setup() {
        setupBackground()
        setupProfileContainerStackView()
   
    }
   
    func setData(profile:UserProfile,following:Bool,isCurrentUser:Bool){
      
            setProfileData(profile: profile)
        
       
            self.setFollowButtonState(isFollowing: following)
        
    }
    func setFollowButtonState(isFollowing:Bool){
     
        if !isCurrentUser{
            UIView.animate(withDuration: 0.1){
                if isFollowing{
                    self.button1.setTitle("Unfollow", for: .normal)
                    self.button1.applyStyle(style: .secondary)
                }
                else{
                    self.button1.setTitle("Follow", for: .normal)
                    self.button1.applyStyle(style: .primary)
                }
            }
            
        }
    }
    func setProfileData(profile:UserProfile){
        UIView.animate(withDuration: 0.1){
            if let string = profile.avatar_url,let url = URL(string:string){
                self.avatarImageView.setImage(url:url )
            }
            self.postCountLabel.setData(number: profile.post_count ?? 0)
            self.followersCountLabel.setData(number: profile.follower_count ?? 0)
            self.followingCountLabel.setData(number: profile.following_count ?? 0)
            
            self.nameLabel.text = profile.full_name
            
            if profile.is_verified == true{
                self.verifiedImage?.isHidden = false
            }
            
            
            self.changeBioLabel(text: profile.bio ?? "")
        }
    }
 
    
    private func changeBioLabel(text:String) {
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
    
   
   
    @objc func followButtonTapped() {
        delegate?.followButtonTapped()
       
    }
    @objc func messageButtonTapped() {
        delegate?.messageButtonTapped()
    }
    @objc func editProfileButtonTapped() {
        delegate?.editProfileButtonTapped()
    }
    @objc func shareProfileButtonTapped() {
        delegate?.shareProfileButtonTapped()
    }
    @objc func didTapFollower() {
        delegate?.didTapFollowerCount()
    }
    @objc func didTapFollowing() {
        delegate?.didTapFollowingCount()
    }
    func configureButtonsForTarget(){
        if self.isCurrentUser{
            
            button1.addTarget(self, action: #selector(editProfileButtonTapped), for: .touchUpInside)
            button2.addTarget(self, action: #selector(shareProfileButtonTapped), for: .touchUpInside)
            
            button1.setTitle("Edit Profile")
            button2.setTitle("Share Profile")
            
            button1.applyStyle(style: .secondary)
        }else{
            button1.addTarget(self, action: #selector(followButtonTapped), for: .touchUpInside)
            button2.addTarget(self, action: #selector(messageButtonTapped), for: .touchUpInside)
        }
    }
    func setupButtons(){
       configureButtonsForTarget()
        button1.translatesAutoresizingMaskIntoConstraints = false
        button2.translatesAutoresizingMaskIntoConstraints = false
        let hStack = buttonsStackView
        
        hStack.axis = .horizontal
        hStack.alignment = .center
        hStack.spacing = 12
        hStack.distribution = .fillEqually
        hStack.translatesAutoresizingMaskIntoConstraints = false
        
        hStack.addArrangedSubview(button1)
        hStack.addArrangedSubview(button2)
        
        self.profileInfoContainerStackView.addArrangedSubview(hStack)
        
        NSLayoutConstraint.activate([
            hStack.widthAnchor.constraint(equalTo: profileInfoContainerStackView.widthAnchor),
            button1.heightAnchor.constraint(equalToConstant: 40),
            button2.heightAnchor.constraint(equalToConstant: 40),
        ])
    }
    func setupBioLabel(){
        bioLabel.font = .systemFont(ofSize: 15)
        bioLabel.textAlignment = .left
        bioLabel.translatesAutoresizingMaskIntoConstraints = false
        changeBioLabel(text: "")
        
       
       
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

           nameLabel.text = "Unknown"
           nameLabel.translatesAutoresizingMaskIntoConstraints = false

           profileInfoContainerStackView.addArrangedSubview(nameLabel)

      
//        nameLabel.widthAnchor.constraint(
//            lessThanOrEqualTo: profileInfoContainerView.widthAnchor,
//            multiplier: 0.60
//
//        ).isActive = true
        
        setupVerifiedIMageView()
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
        verifiedImage.isHidden = true
       
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
        
        followersCountLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapFollower)))
        followingCountLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapFollowing)))
        
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
       setupButtons()
    }
    func setupBackground() {
        profileInfoContainerView.translatesAutoresizingMaskIntoConstraints = false
        profileInfoContainerView.backgroundColor = .systemBackground
        profileInfoContainerView.layer.cornerRadius = 20
        profileInfoContainerView.layer.borderColor = UIColor.gray.withAlphaComponent(0.4).cgColor
        profileInfoContainerView.layer.borderWidth = 1
        // ✅ Shadow (PROFILE HEADER ONLY)
        profileInfoContainerView.layer.shadowColor = UIColor.gray.withAlphaComponent(0.4).cgColor
        profileInfoContainerView.layer.shadowOpacity = 0.7
          profileInfoContainerView.layer.shadowRadius = 9
          profileInfoContainerView.layer.shadowOffset = CGSize(width: 0, height: 6)

          // IMPORTANT: shadow must not be clipped
          profileInfoContainerView.clipsToBounds = false

        self.addSubview(profileInfoContainerView)
        
        NSLayoutConstraint.activate([
            profileInfoContainerView.topAnchor.constraint(equalTo: self.topAnchor, constant: 12),
            profileInfoContainerView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 12),
            profileInfoContainerView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 12),
            profileInfoContainerView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -12),
            
    ])
    }
   
    
}
