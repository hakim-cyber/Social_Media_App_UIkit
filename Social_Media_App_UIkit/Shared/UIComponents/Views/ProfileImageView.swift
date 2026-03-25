//
//  ProfileImageView.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 9/29/25.
//

import UIKit

class ProfileImageView: UIView {
    var onTap: (() -> Void)?
    let imageView: UIImageView = UIImageView(image:.init(systemName: "person.fill"))
    let containerView: UIView = UIView()
    var plusImageView: UIImageView!
    // MARK: - Properties
    var imageColor: UIColor = .white
    var borderWidth: CGFloat = 2
    
    var borderColor: UIColor = .white
   
    
    var shadowColor: UIColor = .black
    
    var shadowOpacity: Float = 0.0
    
    var shadowOffset: CGSize = CGSize(width: 0, height: 0)
    var shadowRadius: CGFloat = 0
    
    var placeholderImage: UIImage?
    var showPlus: Bool = false
    
   
    var plusBackground:UIColor = .label
    var plusColor:UIColor = .systemBackground
    
    // MARK: - Initializer
    init(frame: CGRect = .zero,
         image: UIImage? = nil,
         placeholder: UIImage? = UIImage(named: "noProfile"),
         backgroundColor: UIColor = .label,
         borderWidth: CGFloat = 3,
         imageColor: UIColor = .label,
         borderColor: UIColor = .label,
         showPlus:Bool = true,plusBackground:UIColor = .blue,plusColor:UIColor = .systemBackground) {
        
        super.init(frame: frame)
        self.containerView.backgroundColor = backgroundColor
        self.imageView.image = image
        self.placeholderImage = placeholder
        self.borderWidth = borderWidth
        self.borderColor = borderColor
      
        self.showPlus  = showPlus
        self.plusBackground = plusBackground
        self.imageColor = imageColor
        setupView()
        setupPlusView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupPlusView()
    }
    
      private func addTapGesture() {
          let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
          self.isUserInteractionEnabled = true
          self.addGestureRecognizer(tap)
      }
      
      @objc private func handleTap() {
          onTap?()
       
      }
   
    
    // MARK: - Setup
    private func setupView() {
        addTapGesture()
        self.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(containerView)
        imageView.tintColor = imageColor
        
        imageView.image = (imageView.image ?? placeholderImage)
        imageView.contentMode = .scaleAspectFill
        
        containerView.clipsToBounds = true
        containerView.contentMode = .scaleAspectFill
        containerView.layer.borderColor = UIColor.white.cgColor
        containerView.layer.borderWidth = 5
      
       
        
        imageView.translatesAutoresizingMaskIntoConstraints  = false
        self.containerView.addSubview(imageView)
        let padding: CGFloat = 0 // adjust as needed
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            containerView.widthAnchor.constraint(equalTo: self.widthAnchor),
            containerView.heightAnchor.constraint(equalTo: self.heightAnchor),
            
            imageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            imageView.widthAnchor.constraint(equalTo: containerView.widthAnchor),
            imageView.heightAnchor.constraint(equalTo: containerView.heightAnchor)
        ])
    }
    func setupPlusView(){
        if showPlus{
         
            self.plusImageView = UIImageView(image: UIImage(systemName: "plus.circle.fill"))
            plusImageView.tintColor = plusColor
            
            plusImageView.backgroundColor = borderColor
            plusImageView.contentMode = .scaleAspectFit
            plusImageView.clipsToBounds = true
            addSubview(plusImageView)
            
            
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.layer.cornerRadius = containerView.bounds.width / 2
            imageView.layer.cornerRadius = imageView.bounds.width / 2
        
    
        
        guard showPlus, let plus = plusImageView else { return }
           
           let plusSize: CGFloat = bounds.width * 0.25 // 25% of profile width
           plus.frame = CGRect(
            x: bounds.width - plusSize * 1.2 ,
            y: bounds.height - plusSize * 1.2,
               width: plusSize,
               height: plusSize
           )
           plus.layer.cornerRadius = plusSize / 2
        
       }
   
    
    
    // MARK: - Set Image with Optional Animation
    func setImage(_ newImage: UIImage?, animated: Bool = true) {
        guard animated else {
            imageView.image = newImage ?? placeholderImage
            return
        }
        UIView.transition(with: self,
                          duration: 0.3,
                          options: .transitionCrossDissolve,
                          animations: { self.imageView.image = newImage ?? self.placeholderImage },
                          completion: nil)
    }
}

let profileImageView = ProfileImageView(
    frame: CGRect(x: 100, y: 100, width: 220, height: 220),
    placeholder: UIImage(systemName: "person.circle"),
    borderWidth: 2,
    borderColor: .label,
    showPlus: true
  
)

#Preview {
    profileImageView
}
