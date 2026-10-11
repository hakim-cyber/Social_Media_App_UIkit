//
//  PostImageSelectView.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 10/5/25.
//

import UIKit

class PostImageSelectView: UIView {
    var onTap: (() -> Void)?
    var cornerRadius:CGFloat = 15
    var image:UIImage? = nil
    let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGray5
        
        return view
    }()
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    let plusImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "plus",withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .bold))
        imageView.tintColor = .label
        return imageView
    }()
    init(frame: CGRect = .zero,cornerRadius:CGFloat = 15,image:UIImage? = nil) {
        
        super.init(frame: frame)
         self.cornerRadius = cornerRadius
         self.image = image
        setupView()
         
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
   
    private func setupView() {
        self.translatesAutoresizingMaskIntoConstraints = false
       setupContainerView()
        setupImageView()
        addTapGesture()
    }
    func setupContainerView(){
       
        self.addSubview(containerView)
        containerView.layer.cornerRadius = cornerRadius
        imageView.layer.cornerRadius = cornerRadius
        containerView.resizeToParent()
    }
    var alreadyAddedPlus:Bool = false
    var alreadyAddedImageView:Bool = false
    func setImage(image:UIImage?){
        self.image = image
        
        self.setupImageView()
    }
    func setupImageView(){
        if self.image  != nil{
            plusImageView.isHidden = true
            imageView.isHidden = false
            imageView.image = self.image
          
            if !alreadyAddedImageView{
                alreadyAddedImageView = true
                containerView.addSubview(imageView)
                imageView.resizeToParent()
            }
            
        }else{
            plusImageView.isHidden = false
            imageView.isHidden = true
            if !alreadyAddedPlus{
                alreadyAddedPlus = true
                containerView.addSubview(plusImageView)
                
                NSLayoutConstraint.activate([
                    plusImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
                    plusImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
                ])
            }
        }
    }
    
      private func addTapGesture() {
         
          let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
          self.isUserInteractionEnabled = true
          self.addGestureRecognizer(tap)
      }
    @objc private func handleTap() {
        print("tap")
        onTap?()
     
    }
}


#Preview {
    PostImageSelectView()
}
