//
//  ProfilePostCell.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 12/23/25.
//

import UIKit

class ProfilePostCell:UICollectionViewCell{
    static let reuseID = "ProfilePostCell"
    var post: Post?

    private let imageView = RoundedImageView(url: nil, cornerRadius: 20)

       override init(frame: CGRect) {
           super.init(frame: frame)
           contentView.clipsToBounds = true

           imageView.translatesAutoresizingMaskIntoConstraints = false
         
           contentView.addSubview(imageView)

           NSLayoutConstraint.activate([
               imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
               imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
               imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
               imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
           ])
       }

       required init?(coder: NSCoder) { fatalError() }

       override func prepareForReuse() {
           super.prepareForReuse()
           imageView.image = nil
       }

    func configure(post:Post) {
        self.post = post
        self.imageView.setImage(url: post.imageURL)
       }

       
}
