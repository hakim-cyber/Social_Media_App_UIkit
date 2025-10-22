//
//  PostFeedTableViewCell.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 10/11/25.
//

import UIKit
import Kingfisher

protocol PostCellDelegate: AnyObject {
    func postCellDidTapAvatar(_ cell: PostFeedTableViewCell)
    func postCellDidTapMore(_ cell: PostFeedTableViewCell)
    func postCellDidTapLike(_ cell: PostFeedTableViewCell)
    func postCellDidTapComment(_ cell: PostFeedTableViewCell)
    func postCellDidTapSave(_ cell: PostFeedTableViewCell)
}


final class PostFeedTableViewCell: UITableViewCell {

    // MARK: - Public
    weak var delegate: PostCellDelegate?
    var post: Post?

    static let reuseID = "PostFeedTableViewCell"

    // MARK: - UI
    let postImageView = RoundedImageView(
        url: nil,
        isCircular: false,
        cornerRadius: AppConstants.UI.postCornerRadius,
        maskedCorners: [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
    )

    let avatarImageView = RoundedImageView(url: nil, isCircular: true)
    var locationView:LocationView?
    let moreButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        b.tintColor = .label
        return b
    }()

    let nameTextView: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.numberOfLines = 1
        l.font = .boldSystemFont(ofSize: 15)
        l.minimumScaleFactor = 0.9
        l.adjustsFontSizeToFitWidth = true
        l.textColor = .label
        l.lineBreakMode = .byTruncatingTail
        return l
    }()

    let likeTextView: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.numberOfLines = 1
        l.textColor = .label
        l.font = .systemFont(ofSize: 12, weight: .bold)
        l.lineBreakMode = .byTruncatingTail
        return l
    }()

    let commentTextView: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.numberOfLines = 1
        l.textColor = .label
        l.font = .systemFont(ofSize: 12, weight: .bold)
        l.lineBreakMode = .byTruncatingTail
        return l
    }()

    let likeButton = ToggleButton()
    let saveButton = ToggleButton()

    let commentButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setImage(UIImage(systemName: "bubble.right"), for: .normal)
        b.tintColor = .label
        b.imageView?.contentMode = .scaleAspectFit
        return b
    }()

    let descriptionLabel: ExpandableLabel = {
        let l = ExpandableLabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.numberOfLines = 0
        l.collapsedNumberOfLines = 2
        l.font = .systemFont(ofSize: 12)
        l.textColor = .label
        return l
    }()

    let topTextStackView: UIStackView = {
        let s = UIStackView()
        s.translatesAutoresizingMaskIntoConstraints = false
        s.axis = .vertical
        s.alignment = .leading
        s.spacing = 8
        return s
    }()

    let topContainerView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .glassBackground
        v.layer.cornerRadius = AppConstants.UI.postCornerRadius
        v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        v.layer.cornerCurve = .continuous
        v.clipsToBounds = true
        return v
    }()

    let bottomContainerView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .clear
        return v
    }()

    // MARK: - Init
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
        postImageView.image = nil
        postImageView.kf.cancelDownloadTask()
        avatarImageView.image = nil
        avatarImageView.kf.cancelDownloadTask()
        nameTextView.text = nil
        likeTextView.text = nil
        commentTextView.text = nil
        descriptionLabel.attributedText = nil
       
    }

    // MARK: - Public configure
    func configure(with post: Post) {
        self.post = post
        postImageView.setImage(url: post.imageURL)
        if let avatarURL = post.author.avatarURL { avatarImageView.setImage(url: avatarURL) }
        nameTextView.text = post.author.fullName

        changeCountOnLabel(count: post.likeCount, label: likeTextView)
        changeCountOnLabel(count: post.commentCount, label: commentTextView)

        // Make sure label font set BEFORE attributed text
        descriptionLabel.font = .systemFont(ofSize: 12)
        descriptionLabel.textAlignment = .left
        changeDescriptionAndUsername(post: post)
        
        locationView?.setLocation(post.location)
        
    }

    // MARK: - Layout & setup
    private func setupView() {
        setupTopContainerView()
        setupPostImageView()
        setupBottomContainerView()
    }

    private func setupTopContainerView() {
        contentView.addSubview(topContainerView)

        // avatar
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        topContainerView.addSubview(avatarImageView)
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapAvatar)))

        // more
        moreButton.addTarget(self, action: #selector(didTapMore), for: .touchUpInside)
        topContainerView.addSubview(moreButton)

        // stack (name + location)
        topContainerView.addSubview(topTextStackView)
        topTextStackView.addArrangedSubview(nameTextView)
        let locationView = LocationView(text: post?.location)
        self.locationView = locationView
        topTextStackView.addArrangedSubview(locationView)
        topTextStackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapAvatar)))

        NSLayoutConstraint.activate([
            // header pinned to top of the cell (sibling to image)
            topContainerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            topContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            topContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            topContainerView.heightAnchor.constraint(equalToConstant: 56),

            avatarImageView.leadingAnchor.constraint(equalTo: topContainerView.leadingAnchor, constant: 15),
            avatarImageView.centerYAnchor.constraint(equalTo: topContainerView.centerYAnchor),
            avatarImageView.heightAnchor.constraint(equalTo: topContainerView.heightAnchor, multiplier: 0.6),
            avatarImageView.widthAnchor.constraint(equalTo: avatarImageView.heightAnchor),

            moreButton.trailingAnchor.constraint(equalTo: topContainerView.trailingAnchor, constant: -15),
            moreButton.centerYAnchor.constraint(equalTo: topContainerView.centerYAnchor),

            topTextStackView.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 8),
            topTextStackView.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
            topTextStackView.trailingAnchor.constraint(lessThanOrEqualTo: moreButton.leadingAnchor, constant: -12),
            topTextStackView.heightAnchor.constraint(equalTo: avatarImageView.heightAnchor)
        ])
    }

    private func setupPostImageView() {
        contentView.addSubview(postImageView)
        postImageView.translatesAutoresizingMaskIntoConstraints = false
        postImageView.isUserInteractionEnabled = true
        postImageView.layer.cornerCurve = .continuous
        postImageView.clipsToBounds = true

        NSLayoutConstraint.activate([
            postImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            postImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            postImageView.topAnchor.constraint(equalTo: topContainerView.bottomAnchor, constant: 0),
            postImageView.heightAnchor.constraint(equalTo: postImageView.widthAnchor,
                                                  multiplier: AppConstants.Media.defaultPostCropRatio.height)
        ])
    }

    private func setupBottomContainerView() {
        contentView.addSubview(bottomContainerView)
      
        // Like
        likeButton.normalImage = UIImage(systemName: "heart")
        likeButton.toggledImage = UIImage(systemName: "heart.fill")
        likeButton.normalColor = .label
        likeButton.toggledColor = .systemRed
        likeButton.onToggle = { [weak self] isLiked in self?.didTapLike(isLiked: isLiked) }

        bottomContainerView.addSubview(likeButton)
        bottomContainerView.addSubview(likeTextView)

        // Comment
        commentButton.addTarget(self, action: #selector(didTapComment), for: .touchUpInside)
        bottomContainerView.addSubview(commentButton)
        bottomContainerView.addSubview(commentTextView)

        // Save
        saveButton.normalImage = UIImage(systemName: "bookmark")
        saveButton.toggledImage = UIImage(systemName: "bookmark.fill")
        saveButton.normalColor = .label
        saveButton.toggledColor = .label
        saveButton.imageView.contentMode = .scaleToFill
        saveButton.onToggle = { [weak self] isSaved in self?.didTapSave(isSaved: isSaved) }
        bottomContainerView.addSubview(saveButton)

        // Description
        descriptionLabel.onToggle = { [weak self] _ in
            // animate cell height change
            guard let tableView = self?.parentTableView else { return }
            tableView.beginUpdates(); tableView.endUpdates()
        }
        bottomContainerView.addSubview(descriptionLabel)

        NSLayoutConstraint.activate([
            // Container around buttons + description
            bottomContainerView.topAnchor.constraint(equalTo: postImageView.bottomAnchor),
            bottomContainerView.leadingAnchor.constraint(equalTo: postImageView.leadingAnchor),
            bottomContainerView.trailingAnchor.constraint(equalTo: postImageView.trailingAnchor),

            // Buttons row
            likeButton.leadingAnchor.constraint(equalTo: bottomContainerView.leadingAnchor),
            likeButton.topAnchor.constraint(equalTo: bottomContainerView.topAnchor, constant: 5),
            likeButton.widthAnchor.constraint(equalToConstant: 30),
            likeButton.heightAnchor.constraint(equalToConstant: 24),

            likeTextView.leadingAnchor.constraint(equalTo: likeButton.trailingAnchor, constant: 0),
            likeTextView.centerYAnchor.constraint(equalTo: likeButton.centerYAnchor),
            likeTextView.heightAnchor.constraint(equalToConstant: 20),
            likeTextView.widthAnchor.constraint(lessThanOrEqualToConstant: 50),

            commentButton.leadingAnchor.constraint(equalTo: likeTextView.trailingAnchor, constant: 10),
            commentButton.centerYAnchor.constraint(equalTo: likeButton.centerYAnchor),
            commentButton.widthAnchor.constraint(equalToConstant: 30),
            commentButton.heightAnchor.constraint(equalToConstant: 22),

            commentTextView.leadingAnchor.constraint(equalTo: commentButton.trailingAnchor, constant: 0),
            commentTextView.centerYAnchor.constraint(equalTo: commentButton.centerYAnchor),
            commentTextView.heightAnchor.constraint(equalToConstant: 20),
            commentTextView.widthAnchor.constraint(lessThanOrEqualToConstant: 50),

            saveButton.trailingAnchor.constraint(equalTo: bottomContainerView.trailingAnchor, constant: -5),
            saveButton.centerYAnchor.constraint(equalTo: likeButton.centerYAnchor),
            saveButton.widthAnchor.constraint(equalToConstant: 20),
            saveButton.heightAnchor.constraint(equalToConstant: 18),

            // Description BETWEEN like & save buttons width-wise
            descriptionLabel.leadingAnchor.constraint(equalTo: likeButton.leadingAnchor, constant: 7),
            descriptionLabel.trailingAnchor.constraint(equalTo: saveButton.leadingAnchor, constant: -9),
            descriptionLabel.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 14),
            
            // In setupBottomContainerView(), add this to the constraints block:
            descriptionLabel.bottomAnchor.constraint(equalTo: bottomContainerView.bottomAnchor, constant: -12),
            contentView.bottomAnchor.constraint(equalTo: bottomContainerView.bottomAnchor, constant: 12)
        ])
    }

    // MARK: - Data/Actions
    private func changeDescriptionAndUsername(post: Post) {
        let text = "*\(post.author.username)* \(post.caption)"
        // Match label font size for correct truncation behavior
        let attr = NSAttributedString(
            text.makeAttributedString(
                mainColor: .label,
                secondaryColor: .label,
                secondaryWeight: .heavy,
                size: 12
            )
        )
        descriptionLabel.attributedText = attr
    }

    private func changeCountOnLabel(count: Int, label: UILabel) {
        label.text = "\(count.shortFormatted)"
    }

    @objc private func didTapMore() {
        delegate?.postCellDidTapMore(self)
    }

    @objc private func didTapComment() {
        delegate?.postCellDidTapComment(self)
    }

    @objc private func didTapAvatar() {
        delegate?.postCellDidTapAvatar(self)
    }

    private func didTapLike(isLiked: Bool) {
        delegate?.postCellDidTapLike(self)
    }

    private func didTapSave(isSaved: Bool) {
        delegate?.postCellDidTapSave(self)
    }
}

// MARK: - Helpers
private extension UITableViewCell {
    /// Walks up the view tree to find the parent table view (for begin/end updates)
    var parentTableView: UITableView? {
        var v: UIView? = superview
        while v != nil && (v as? UITableView) == nil { v = v?.superview }
        return v as? UITableView
    }
}
