//
//  FollowButton.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 12/29/25.
//

import UIKit

class FollowButton: UIButton {
   
    var isFollowing:Bool = false{
        didSet{
            configureDesign()
        }
    }
    var isFollower:Bool = false{
        didSet{
            configureDesign()
        }
    }

        override init(frame: CGRect) {
            super.init(frame: frame)
            configure()
            configureDesign()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

    init(){
          
            super.init(frame: .zero)
            configureDesign()
            configure()
        }
        private func configure(){
            self.layer.cornerRadius = self.frame.width / 2
            
            
            configuration?.imagePadding = 0
            setTitleColor(.white, for: .normal)
            
            titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            translatesAutoresizingMaskIntoConstraints = false
        }
    func configureDesign(){
        if !isFollowing && !isFollower{
            self.setTitle("Follow", for: .normal)
            self.setTitleColor(.white, for: .normal)
            self.backgroundColor = .electricPurple
            
        }else if isFollowing && !isFollower{
            self.setTitle("Following", for: .normal)
            self.setTitleColor(.label, for: .normal)
            self.backgroundColor = UIColor.tertiarySystemFill
            
        }else if !isFollowing && isFollower{
            self.setTitle("Follow back", for: .normal)
            self.setTitleColor(.white, for: .normal)
            self.backgroundColor = .electricPurple
        }else{
            self.setTitle("Friends", for: .normal)
            self.setTitleColor(.label, for: .normal)
            self.backgroundColor = UIColor.tertiarySystemFill
        }
    }
      
}
