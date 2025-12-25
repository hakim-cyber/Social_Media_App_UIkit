//
//  PostCommentTableViewCell.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 12/4/25.
//

import UIKit
import Kingfisher

protocol PostCommentCellDelegate: AnyObject {
   
    func commentCellDidTapMore(_ cell: PostCommentTableViewCell)
    func commentCellDidTapAvatar(_ cell: PostCommentTableViewCell)
   
}


final class PostCommentTableViewCell: UITableViewCell {
    
    // MARK: - Public
    weak var delegate: PostCommentCellDelegate?
    var comment: PostComment?
    
    static let reuseID = "PostCommentTableViewCell"
    
    // MARK: - UI
   
    let avatarImageView = RoundedImageView(url: nil, isCircular: true)
    
    let moreButton: UIButton = {
        let config = UIImage.SymbolConfiguration(pointSize: 17, weight: .regular, scale: .default)
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false

        let image = UIImage(systemName: "ellipsis", withConfiguration: config)
        b.setImage(image, for: .normal)

        b.tintColor = .secondaryLabel
        return b
    }()
    let usernameTextView: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.numberOfLines = 1
        l.font = .boldSystemFont(ofSize: 16)
        l.minimumScaleFactor = 0.9
        l.adjustsFontSizeToFitWidth = true
        l.textColor = .label
        l.lineBreakMode = .byTruncatingTail
        return l
    }()
    let commentTextView: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.numberOfLines = 0
        l.font = .systemFont(ofSize: 15)
        l.minimumScaleFactor = 0.9
        l.adjustsFontSizeToFitWidth = true
        l.textColor = .label
        l.lineBreakMode = .byTruncatingTail
        l.textAlignment = .left
        return l
    }()
    let dateTextLabel:UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.numberOfLines = 1
        l.textColor = .secondaryLabel
        l.font = .systemFont(ofSize:13)
        return l
    }()
    let translateButton = ToggleTextButton()
    
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.backgroundColor = .clear
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        selectionStyle = .none
        contentView.backgroundColor = .clear
        setupView()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        avatarImageView.image = nil
        avatarImageView.kf.cancelDownloadTask()
        usernameTextView.text = nil
       
        commentTextView.text = nil
        dateTextLabel.text = nil
      
        translateButton.isToggled = false
    }

    // MARK: - Public configure
    func configure(with comment: PostComment) {
        self.comment = comment
      
        if let avatarURL = comment.author.avatarURL { avatarImageView.setImage(url: avatarURL) }
        usernameTextView.text = comment.author.username

        commentTextView.text = comment.text
        
        dateTextLabel.text = comment.created_at.timeAgoDisplay() + " ∘"
        translateButton.isToggled = false
        
    }

    // MARK: - Layout & setup
    private func setupView() {
        
      
        setupTopViews()
        setupTextView()
        setupBottomView()
    }
    func setupBottomView(){
        contentView.addSubview(dateTextLabel)
        
        translateButton.normalText = "See translation"
        translateButton.toggledText =  "See original"
        translateButton.normalColor = .secondaryLabel
        translateButton.toggledColor = .secondaryLabel
        translateButton.onToggle = { [weak self] translated in self?.didTapTranslate(isTransalated: translated) }
        contentView.addSubview(translateButton)
        
        NSLayoutConstraint.activate([
            
             translateButton.leadingAnchor.constraint(equalTo: dateTextLabel.trailingAnchor, constant: 5),
             translateButton.centerYAnchor.constraint(equalTo: dateTextLabel.centerYAnchor),
           
             translateButton.heightAnchor.constraint(equalToConstant:25),

             dateTextLabel.leadingAnchor.constraint(equalTo: commentTextView.leadingAnchor),
             dateTextLabel.topAnchor.constraint(equalTo: commentTextView.bottomAnchor, constant: 5),
             dateTextLabel.heightAnchor.constraint(equalToConstant:25),
             dateTextLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
             contentView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 16)
        ])
    }
    
    func setupTextView(){
        self.contentView.addSubview(commentTextView)
        
        NSLayoutConstraint.activate([
            commentTextView.leadingAnchor.constraint(equalTo: usernameTextView.leadingAnchor),
            commentTextView.trailingAnchor.constraint(equalTo: moreButton.trailingAnchor),
            commentTextView.topAnchor.constraint(equalTo: usernameTextView.bottomAnchor,constant: 5),
           
        ])
        
    }
    func setupTopViews(){
        setupAvatarView()
        
        self.contentView.addSubview(usernameTextView)
       
        
        moreButton.addTarget(self, action: #selector(didTapMore), for: .touchUpInside)
        usernameTextView.isUserInteractionEnabled = true   // ✅ REQUIRED
        usernameTextView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapAvatar)))
        
        self.contentView.addSubview(moreButton)
        
        NSLayoutConstraint.activate([
            usernameTextView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            usernameTextView.leadingAnchor.constraint(equalTo: self.avatarImageView.trailingAnchor,constant: 5),
            usernameTextView.heightAnchor.constraint(equalToConstant: 20),
           
            moreButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -26),
            moreButton.centerYAnchor.constraint(equalTo: usernameTextView.centerYAnchor),
        ])
    }
    func setupAvatarView(){
        self.contentView.addSubview(avatarImageView)
        avatarImageView.isUserInteractionEnabled = true   // ✅ REQUIRED
        avatarImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapAvatar)))
        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: self.contentView.topAnchor,constant: 0),
            avatarImageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor,constant: 16),
            avatarImageView.heightAnchor.constraint(equalToConstant: 40),
            avatarImageView.widthAnchor.constraint(equalToConstant: 40),
            
           

        ])
    }
    
    private func didTapTranslate(isTransalated: Bool) {
      
    }
     @objc private func didTapMore() {
         delegate?.commentCellDidTapMore(self)
    }
    @objc private func didTapAvatar() {
        print("didTapAvatar")
        delegate?.commentCellDidTapAvatar(self)
   }
}
