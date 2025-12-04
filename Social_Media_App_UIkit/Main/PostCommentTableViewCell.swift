//
//  PostCommentTableViewCell.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 12/4/25.
//

import UIKit
import Kingfisher



final class PostCommentTableViewCell: UITableViewCell {
    
    // MARK: - Public

    var comment: PostComment?
    
    static let reuseID = "PostCommentTableViewCell"
    
    // MARK: - UI
   
    let avatarImageView = RoundedImageView(url: nil, isCircular: true)
    
    let moreButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        b.tintColor = .label
        return b
    }()
    let usernameTextView: UILabel = {
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
}
