//
//  PostFeedTableViewCell-View.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 10/12/25.
//

import UIKit


class PostFeedTableViewCell_View: UIView {
    weak var delegate: PostCellDelegate?
    var post:Post? = nil
    let postImageView = RoundedImageView(url: nil, isCircular: false, cornerRadius: AppConstants.UI.postCornerRadius)
    let avatarImageView = RoundedImageView(url: nil,isCircular: true)
    let moreButton:UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        view.tintColor = .label
        return view
    }()
    let nameTextView:UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 1
        view.font = .boldSystemFont(ofSize: 15)
        
        view.textColor = .label
        view.lineBreakMode = .byTruncatingTail
       
        return view
    }()
   
    let topTextStackView:UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.alignment = .leading
        view.spacing = 8
        return view
    }()
    let topContainerView:UIView = {
        let view = UIView()
      
        view.applyUltraThinMaterial(blurStyle: .systemChromeMaterial)
        view.layer.cornerRadius = AppConstants.UI.postCornerRadius
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    init(frame: CGRect = .zero,post:Post) {
        self.post = post
        super.init(frame:frame )
        setupView()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView(){
        setupPostImageView()
        setupTopContainerView()
    }
    func setupPostImageView(){
        if let post{
            postImageView.setImage(url: post.imageURL)
        }
        self.addSubview(postImageView)
        postImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            postImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor,constant: 16),
            postImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor,constant: -16),
            postImageView.heightAnchor.constraint(equalTo: postImageView.widthAnchor, multiplier: AppConstants.Media.defaultPostCropRatio.height),
            postImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
    func setupTopContainerView(){
        self.postImageView.addSubview(topContainerView)
        
        setupAvatarImageView()
        setupMoreButton()
        setupTextViews()
        NSLayoutConstraint.activate([
            self.topContainerView.topAnchor.constraint(equalTo: self.postImageView.topAnchor),
            self.topContainerView.leadingAnchor.constraint(equalTo: self.postImageView.leadingAnchor),
            self.topContainerView.trailingAnchor.constraint(equalTo: self.postImageView.trailingAnchor),
            self.topContainerView.heightAnchor.constraint(equalTo: self.postImageView.heightAnchor, multiplier: 0.14)
        ])
    }
    func setupAvatarImageView(){
        if let avatarUrl = post?.author.avatarURL{
            avatarImageView.setImage(url: avatarUrl)
        }
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        self.topContainerView.addSubview(avatarImageView)
        NSLayoutConstraint.activate([
            self.avatarImageView.leadingAnchor.constraint(equalTo: self.topContainerView.leadingAnchor, constant: 15),
            self.avatarImageView.centerYAnchor.constraint(equalTo: self.topContainerView.centerYAnchor),
            self.avatarImageView.heightAnchor.constraint(equalTo:self.topContainerView.heightAnchor,multiplier: 0.6),
            self.avatarImageView.widthAnchor.constraint(equalTo:self.avatarImageView.heightAnchor),
            
        ])
    }
    func setupTextViews(){
        if let post{
            self.nameTextView.text = post.author.fullName
           
        }
        let locationView = LocationView(text: self.post?.location)
        self.topContainerView.addSubview(topTextStackView)
        
        self.topTextStackView.addArrangedSubview(nameTextView)
        self.topTextStackView.addArrangedSubview(locationView)
       
        NSLayoutConstraint.activate([
            topTextStackView.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 8),
            topTextStackView.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
            topTextStackView.trailingAnchor.constraint(lessThanOrEqualTo: moreButton.trailingAnchor, constant: -30),
            topTextStackView.heightAnchor.constraint(equalTo:avatarImageView.heightAnchor)
            
           ])
        
        
    }
    func setupMoreButton(){
        moreButton.addTarget(self, action: #selector(didTapMore), for: .touchUpInside)
        self.topContainerView.addSubview(moreButton)
        NSLayoutConstraint.activate([
            moreButton.trailingAnchor.constraint(equalTo: topContainerView.trailingAnchor, constant: -15),
            moreButton.centerYAnchor.constraint(equalTo: topContainerView.centerYAnchor),
         
            
           ])
    }
    @objc func didTapMore(){
      
    }
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}

#Preview(){
    PostFeedTableViewCell_View(post: Post.mockPost)
}
protocol PostCellDelegate: AnyObject {
    func postCellDidTapAvatar(_ cell: PostFeedTableViewCell)
    func postCellDidTapMore(_ cell: PostFeedTableViewCell)
    func postCellDidTapLike(_ cell: PostFeedTableViewCell)
    func postCellDidTapComment(_ cell: PostFeedTableViewCell)
    func postCellDidTapSave(_ cell: PostFeedTableViewCell)
}
