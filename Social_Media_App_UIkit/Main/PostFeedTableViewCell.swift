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
        l.font = .systemFont(ofSize: 15, weight: .bold)
        l.lineBreakMode = .byTruncatingTail
        return l
    }()

    let commentTextView: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.numberOfLines = 1
        l.textColor = .label
        l.font = .systemFont(ofSize: 15, weight: .bold)
        l.lineBreakMode = .byTruncatingTail
        return l
    }()

    let likeButton = ToggleButton()
    let saveButton = ToggleButton()

    let commentButton: UIButton = {
        let b = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .light)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setImage(UIImage(systemName: "bubble.right", withConfiguration: config), for: .normal)
        b.tintColor = .label
        b.imageView?.contentMode = .scaleAspectFit
        return b
    }()

    let descriptionLabel: ExpandableLabel = {
        let l = ExpandableLabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.numberOfLines = 0
        l.collapsedNumberOfLines = 2
        l.font = .systemFont(ofSize:15)
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
        v.backgroundColor = .quaternaryLabel
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
        likeButton.isToggled = false
        saveButton.isToggled = false
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
        descriptionLabel.font = .systemFont(ofSize: 15)
        descriptionLabel.textAlignment = .left
        changeDescriptionAndUsername(post: post)
        
        locationView?.setLocation(post.location)
        
        likeButton.isToggled = post.isLiked
        saveButton.isToggled = post.isSaved
        
        
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
       
        let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        tap.numberOfTapsRequired = 2
        postImageView.addGestureRecognizer(tap)
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
        let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .light)
        likeButton.normalImage = UIImage(systemName: "heart", withConfiguration: config)
        likeButton.toggledImage = UIImage(systemName: "heart.fill", withConfiguration: config)
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
        saveButton.normalImage = UIImage(systemName: "bookmark", withConfiguration: config)
        saveButton.toggledImage = UIImage(systemName: "bookmark.fill", withConfiguration: config)
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
            likeButton.widthAnchor.constraint(equalToConstant: 40),
            likeButton.heightAnchor.constraint(equalToConstant:30),

            likeTextView.leadingAnchor.constraint(equalTo: likeButton.trailingAnchor, constant: 0),
            likeTextView.centerYAnchor.constraint(equalTo: likeButton.centerYAnchor),
            likeTextView.heightAnchor.constraint(equalToConstant: 30),
            likeTextView.widthAnchor.constraint(lessThanOrEqualToConstant: 50),

            commentButton.leadingAnchor.constraint(equalTo: likeTextView.trailingAnchor, constant: 10),
            commentButton.centerYAnchor.constraint(equalTo: likeButton.centerYAnchor),
            commentButton.widthAnchor.constraint(equalToConstant: 35),
            commentButton.heightAnchor.constraint(equalToConstant: 25),

            commentTextView.leadingAnchor.constraint(equalTo: commentButton.trailingAnchor, constant: 0),
            commentTextView.centerYAnchor.constraint(equalTo: commentButton.centerYAnchor),
            commentTextView.heightAnchor.constraint(equalToConstant: 20),
            commentTextView.widthAnchor.constraint(lessThanOrEqualToConstant: 50),

            saveButton.trailingAnchor.constraint(equalTo: bottomContainerView.trailingAnchor, constant: -5),
            saveButton.centerYAnchor.constraint(equalTo: likeButton.centerYAnchor),
            saveButton.widthAnchor.constraint(equalToConstant: 30),
            saveButton.heightAnchor.constraint(equalToConstant:25),

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
    @objc func doubleTapped() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        if  !likeButton.isToggled{
            likeButton.isToggled.toggle()
            self.didTapLike(isLiked:  likeButton.isToggled)
        }
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
        guard var post = post else {
            delegate?.postCellDidTapLike(self)
            return
        }

        // Optimistic like count change
        if isLiked {
            post.likeCount += 1
        } else {
            post.likeCount = max(0, post.likeCount - 1)
        }
        self.post = post
        changeCountOnLabel(count: post.likeCount, label: likeTextView)

        delegate?.postCellDidTapLike(self)
    }
   
    private func didTapSave(isSaved: Bool) {
        delegate?.postCellDidTapSave(self)
    }
    func styleTopRoundedView(_ v: UIView) {
        // --- Adaptive background color (same behavior as UILabel) ---
        v.backgroundColor = .secondarySystemBackground

        // --- Rounded top corners ---
        v.layer.cornerRadius = 16
        v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        v.layer.cornerCurve = .continuous
        v.layer.masksToBounds = true

        // --- Remove old border layers (if reusing view) ---
        v.layer.sublayers?
            .filter { $0.name == "TopBorderLayer" }
            .forEach { $0.removeFromSuperlayer() }

        // --- Add custom border on top + left + right ---
        let border = CAShapeLayer()
        border.name = "TopBorderLayer"
        border.strokeColor = UIColor.separator.cgColor   // adaptive (light/dark)
        border.fillColor = UIColor.clear.cgColor
        border.lineWidth = 0.5

        let path = UIBezierPath()
        let w = v.bounds.width
        let h: CGFloat = v.bounds.height

        // Draw only:
        // left edge  (vertical)
        // top edge   (horizontal)
        // right edge (vertical)

        path.move(to: CGPoint(x: 0, y: h))        // bottom-left (start)
        path.addLine(to: CGPoint(x: 0, y: 0))     // left side
        path.addLine(to: CGPoint(x: w, y: 0))     // top side
        path.addLine(to: CGPoint(x: w, y: h))     // right side

        border.path = path.cgPath
        v.layer.addSublayer(border)
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
