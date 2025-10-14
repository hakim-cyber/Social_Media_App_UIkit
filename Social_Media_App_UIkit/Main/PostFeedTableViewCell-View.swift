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
    let postImageView = RoundedImageView(url: nil, isCircular: false, cornerRadius: AppConstants.UI.postCornerRadius,maskedCorners: [.layerMaxXMaxYCorner,.layerMinXMaxYCorner])
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
        view.minimumScaleFactor = 0.9
        view.adjustsFontSizeToFitWidth = true
        view.textColor = .label
        view.lineBreakMode = .byTruncatingTail
       
        return view
    }()

    let likeTextView:UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 1
      
        view.textColor = .label
        view.font = .systemFont(ofSize: 12,weight: .bold)
        view.lineBreakMode = .byTruncatingTail
        return view
    }()
    let likeButton:ToggleButton =  ToggleButton()
    let saveButton:ToggleButton =  ToggleButton()
    
    let descriptionLabel:ExpandableLabel = {
        let descriptionLabel = ExpandableLabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.numberOfLines = 0 // important
        descriptionLabel.collapsedNumberOfLines = 2
        descriptionLabel.font = .systemFont(ofSize: 10)
        descriptionLabel.textColor = .label
        
        return descriptionLabel
    }()
    let commentButton:UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(systemName: "bubble.right"), for: .normal)
        btn.tintColor = .label
        btn.imageView?.contentMode = .scaleAspectFit
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    let commentTextView:UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 1
      
        view.textColor = .label
        view.font = .systemFont(ofSize: 12,weight: .bold)
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
      
        view.backgroundColor = .glassBackground
        view.layer.cornerRadius = AppConstants.UI.postCornerRadius
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    let bottomContainerView:UIView = {
        let view = UIView()
      
       
        view.backgroundColor = .clear
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
        setupBottomContainerView()
    }
    func setupPostImageView(){
        if let post{
            postImageView.setImage(url: post.imageURL)
        }
        self.addSubview(postImageView)
        postImageView.translatesAutoresizingMaskIntoConstraints = false
        postImageView.isUserInteractionEnabled = true
        NSLayoutConstraint.activate([
            postImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor,constant: 16),
            postImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor,constant: -16),
            postImageView.heightAnchor.constraint(equalTo: postImageView.widthAnchor, multiplier: AppConstants.Media.defaultPostCropRatio.height),
            postImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
    func setupTopContainerView(){
        self.addSubview(topContainerView)
        
        setupAvatarImageView()
        setupMoreButton()
        setupTextViews()
        NSLayoutConstraint.activate([
            self.topContainerView.bottomAnchor.constraint(equalTo: self.postImageView.topAnchor),
            self.topContainerView.leadingAnchor.constraint(equalTo: self.postImageView.leadingAnchor),
            self.topContainerView.trailingAnchor.constraint(equalTo: self.postImageView.trailingAnchor),
            self.topContainerView.heightAnchor.constraint(equalTo: self.postImageView.heightAnchor, multiplier: 0.14)
        ])
    }
    func setupBottomContainerView(){
        self.addSubview(bottomContainerView)
        
        self.setupLikeButtonUI()
        setupCommentButtonUI()
        setupSaveButtonUI()
        setupDescriptionLabelUI()
        
        if let post{
            changeDescriptionAndUsername(post: post)
            
        }
        NSLayoutConstraint.activate([
            self.bottomContainerView.topAnchor.constraint(equalTo: self.postImageView.bottomAnchor),
            self.bottomContainerView.leadingAnchor.constraint(equalTo: self.postImageView.leadingAnchor),
            self.bottomContainerView.trailingAnchor.constraint(equalTo: self.postImageView.trailingAnchor),
            bottomContainerView.bottomAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 12)
        ])
    }
    func setupAvatarImageView(){
        if let avatarUrl = post?.author.avatarURL{
            avatarImageView.setImage(url: avatarUrl)
        }
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        self.topContainerView.addSubview(avatarImageView)
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapAvatar)))
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
        topTextStackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapAvatar)))
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
    func setupLikeButtonUI(){
      
        likeButton.normalImage = UIImage(systemName: "heart")
        likeButton.toggledImage = UIImage(systemName: "heart.fill")
        likeButton.normalColor = UIColor.label
        likeButton.toggledColor = .systemRed
       
        

        likeButton.onToggle = {[weak self] isLiked in
            self?.didTapLike(isLiked: isLiked)
        }
        
        self.bottomContainerView.addSubview(likeButton)
      
        NSLayoutConstraint.activate([
            self.likeButton.leadingAnchor.constraint(equalTo: bottomContainerView.leadingAnchor),
            self.likeButton.topAnchor.constraint(equalTo: bottomContainerView.topAnchor, constant: 5),
            self.likeButton.widthAnchor.constraint(equalToConstant: 30),
            self.likeButton.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        self.bottomContainerView.addSubview(likeTextView)
        NSLayoutConstraint.activate([
            self.likeTextView.leadingAnchor.constraint(equalTo: likeButton.trailingAnchor, constant: 0),
            self.likeTextView.centerYAnchor.constraint(equalTo: likeButton.centerYAnchor),
          
            self.likeTextView.heightAnchor.constraint(equalToConstant: 20),
            self.likeTextView.widthAnchor.constraint(lessThanOrEqualToConstant: 50)
        ])
        changeCountOnLabel(count: 60700,label:likeTextView)
        
        
    }
    func setupCommentButtonUI(){
        self.bottomContainerView.addSubview(commentButton)
        
        commentButton.addTarget(self, action: #selector(didTapComment), for: .touchUpInside)
        
          NSLayoutConstraint.activate([
            self.commentButton.leadingAnchor.constraint(equalTo: likeTextView.trailingAnchor , constant: 10),
              self.commentButton.centerYAnchor.constraint(equalTo: likeButton.centerYAnchor),
              self.commentButton.widthAnchor.constraint(equalToConstant: 30),
              self.commentButton.heightAnchor.constraint(equalToConstant: 18)
          ])
          
        self.bottomContainerView.addSubview(commentTextView)
        
        NSLayoutConstraint.activate([
            self.commentTextView.leadingAnchor.constraint(equalTo: commentButton.trailingAnchor, constant: 0),
            self.commentTextView.centerYAnchor.constraint(equalTo: commentButton.centerYAnchor),
          
            self.commentTextView.heightAnchor.constraint(equalToConstant: 20),
            self.commentTextView.widthAnchor.constraint(lessThanOrEqualToConstant: 50)
        ])
        changeCountOnLabel(count: 97,label:commentTextView)
    }
   
    func setupSaveButtonUI(){
        
          saveButton.normalImage = UIImage(systemName: "bookmark")
        saveButton.toggledImage = UIImage(systemName: "bookmark.fill")
        saveButton.normalColor = UIColor.label
        saveButton.toggledColor = .label
        saveButton.imageView.contentMode = .scaleToFill
          saveButton.onToggle = {[weak self] bool in
              self?.didTapSave(isSaved: bool)
          }
          
        self.bottomContainerView.addSubview(saveButton)
        NSLayoutConstraint.activate([
            self.saveButton.trailingAnchor.constraint(equalTo: self.bottomContainerView.trailingAnchor,constant: -5),
            self.saveButton.centerYAnchor.constraint(equalTo:self.likeButton.centerYAnchor),
            
            self.saveButton.widthAnchor.constraint(equalToConstant:20),
            self.saveButton.heightAnchor.constraint(equalToConstant: 15)
        ])
        
    }
    
    
    func setupDescriptionLabelUI(){
        
        descriptionLabel.onToggle = {[weak self] isExpanded in
            // If inside a UITableView/UICollectionView cell, animate height change:
            // tableView?.beginUpdates(); tableView?.endUpdates()
            self?.expandedDescription(isExpanded)
        }
        self.bottomContainerView.addSubview(descriptionLabel)
        NSLayoutConstraint.activate([
            self.descriptionLabel.leadingAnchor.constraint(equalTo: self.likeButton.leadingAnchor,constant: 7),
            self.descriptionLabel.trailingAnchor.constraint(equalTo: self.saveButton.trailingAnchor,constant: -9),
            self.descriptionLabel.topAnchor.constraint(equalTo: self.saveButton.bottomAnchor, constant: 10)
            
            ])
    }
    
    
    func changeDescriptionAndUsername(post:Post){
        let text = "*\(post.author.username)* \(post.caption)"
        let attributedText = NSAttributedString( text.makeAttributedString(mainColor: .label,secondaryColor: .label,secondaryWeight: .heavy,size: 10))
        
        self.descriptionLabel.attributedText = attributedText
       
    }
    
    func expandedDescription(_ bool:Bool){
       print("Expanded: \(bool)")
    }
    func changeCountOnLabel(count:Int,label:UILabel){
        label.text = "\(count.shortFormatted)"
    }
    @objc func didTapMore(){
      print("More")
    }
    @objc func didTapComment(){
        print("Comment")
    }
    @objc func didTapAvatar(){
        print("Avatar")
    }
    func didTapLike(isLiked:Bool){
        print("Like")
    }
    func didTapSave(isSaved:Bool){
        print("save")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        print(descriptionLabel.bounds.width)
        print(bottomContainerView.bounds.width)
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
