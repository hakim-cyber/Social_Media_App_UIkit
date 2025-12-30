//
//  FollowerListCell.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 12/29/25.
//

import UIKit
import Kingfisher


final class FollowerListCell: UITableViewCell {
    
    // MARK: - Public
    weak var delegate: FollowerListCellDelegate?
    var user: UserFollowItem?
    var target:FollowerListTarget?{
        didSet{
            
        }
    }
    static let reuseID = "FollowerListCell"
    
    // MARK: - UI
   
    let avatarImageView = RoundedImageView(url: nil, isCircular: true)
    
    let fullNameTextView: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.numberOfLines = 1
        l.font = .systemFont(ofSize: 16,weight: .bold)
        l.minimumScaleFactor = 0.9
        l.adjustsFontSizeToFitWidth = true
        l.textColor = .label
        l.lineBreakMode = .byTruncatingTail
        return l
    }()
    let usernameTextView: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.numberOfLines = 1
        l.font = .systemFont(ofSize: 11,weight: .light)
        l.minimumScaleFactor = 0.9
        l.adjustsFontSizeToFitWidth = true
        l.textColor = .label
        l.lineBreakMode = .byTruncatingTail
        return l
    }()
    private let stackView: UIStackView = {
        let s = UIStackView()
        s.translatesAutoresizingMaskIntoConstraints = false
        s.axis = .vertical
        s.alignment = .leading
        s.spacing = 5
        s.distribution = .equalSpacing
        return s
    }()

   
    let followButton = FollowButton()
    
    let moreButton: UIButton = {
        let config = UIImage.SymbolConfiguration(pointSize: 17, weight: .regular, scale: .default)
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false

        let image = UIImage(systemName: "ellipsis", withConfiguration: config)
        b.setImage(image, for: .normal)

        b.tintColor = .secondaryLabel
        return b
    }()
    private let buttonStackView: UIStackView = {
        let s = UIStackView()
        s.translatesAutoresizingMaskIntoConstraints = false
        s.axis = .horizontal
        s.alignment = .center
        s.spacing = 12
        s.distribution = .equalCentering
        return s
    }()

   
    
    
    
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
       
        fullNameTextView.text = nil
       
        followButton.isFollower = false
        followButton.isFollowing = false
        
        moreButton.isHidden = false
       
    }

    // MARK: - Public configure
    func configure(with user: UserFollowItem,target:FollowerListTarget) {
        self.target = target
        self.user = user
      
        if let avatarURL = user.avatarURL { avatarImageView.setImage(url: avatarURL) }
        usernameTextView.text = user.username

        fullNameTextView.text = user.fullName
        
        followButton.isFollower = user.isFollower
        followButton.isFollowing = user.isFollowing
       
        moreButton.isHidden = (target == .following)
    }

    // MARK: - Layout & setup
    private func setupView() {
        setupAvatarView()
        setupTextViews()
        setupButtons()
        
    }
    
    let padding:CGFloat = 12
    private func setupTextViews(){
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        fullNameTextView.translatesAutoresizingMaskIntoConstraints = false
        usernameTextView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.addArrangedSubview(fullNameTextView)
        self.stackView.addArrangedSubview(usernameTextView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: padding),
            stackView.topAnchor.constraint(equalTo: avatarImageView.topAnchor, constant: 5),
            stackView.bottomAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: -5)
        ])
    }
    private func setupButtons(){
        self.contentView.addSubview(buttonStackView)
      
        self.buttonStackView.addArrangedSubview(followButton)
        self.buttonStackView.addArrangedSubview(moreButton)
        
        self.contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapAvatar)))
        moreButton.addTarget(self, action: #selector(didTapMore), for: .touchUpInside)
        followButton.addTarget(self, action: #selector(didTapFollow), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            buttonStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            buttonStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            buttonStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            moreButton.widthAnchor.constraint(equalToConstant: 30),
            moreButton.heightAnchor.constraint(equalToConstant: 30),
            
            followButton.widthAnchor.constraint(equalToConstant: 100),
            followButton.topAnchor.constraint(equalTo: contentView.topAnchor,constant: padding),
            followButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,constant: -padding),
        ])
    }
    private func setupAvatarView(){
        self.avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(avatarImageView)
        
        NSLayoutConstraint.activate([
            avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            avatarImageView.heightAnchor.constraint(equalToConstant: 50),
            avatarImageView.heightAnchor.constraint(equalToConstant: 50),
        ])
    }
    
     @objc private func didTapMore() {
         delegate?.didTapMore(cell:self)
    }
    @objc private func didTapFollow(){
        delegate?.didTapFollow(cell:self)
    }
    @objc private func didTapAvatar() {
        print("didTapAvatar")
        delegate?.didTapProfile(cell:self)
   }
}
