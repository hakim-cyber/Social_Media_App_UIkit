//
//  WelcomeView.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 9/22/25.
//

import UIKit


class WelcomeViewController: UIViewController {
  
    let welcome_background_carousel = ImageCarouselView(images: [
     UIImage.welcome_background_1,
     UIImage.welcome_background_2,
     UIImage.welcome_background_3
 ])
   let customPageControl = CustomPageControlDots()
    
    let bottomBaseView:UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    let gradientView: CustomGradientView = {
        let view = CustomGradientView(style: .fadeToBlack)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
   
    var visibleBackgroundImage:Int = 0
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // on a label or cell content view
        view.backgroundColor = .systemBackground
       

        welcome_background_carousel.onPageChanged = { page in
            if page != self.visibleBackgroundImage{
                self.visibleBackgroundImage = page
                self.customPageControl.currentPage = page
                print(page)
            }
        }
        
        
     
        setImageToBackground()
        setBottomBaseView()
        setupPageControl()
        setupTextView()
        setSwipetoUnlockButton()
    }
    
    func setSwipetoUnlockButton(){
        let slideButton = SlideToUnlockView()
        slideButton.translatesAutoresizingMaskIntoConstraints = false
        slideButton.onUnlock = {
            print("Unlocked!")
            
        }
        
        self.view.addSubview(slideButton)
        NSLayoutConstraint.activate([
            slideButton.bottomAnchor.constraint(equalTo: self.bottomBaseView.bottomAnchor, constant: -40),
            slideButton.leadingAnchor.constraint(equalTo: self.bottomBaseView.leadingAnchor, constant: 30),
            slideButton.trailingAnchor.constraint(equalTo: self.bottomBaseView.trailingAnchor, constant: -30)
            
            
        ])
    }
    private func setupTextView() {
           // Small music note icon + "Jungle Pulse"
           let iconImageView = UIImageView(image: UIImage(systemName: "sparkles"))
           iconImageView.tintColor = UIColor.electricPurple
           iconImageView.translatesAutoresizingMaskIntoConstraints = false
           
           let titleLabelTop = UILabel()
           titleLabelTop.text = "Aura Social Media"
           titleLabelTop.textColor = UIColor.label
        titleLabelTop.font = UIFont.systemFont(ofSize: 14, weight: .light)
           titleLabelTop.translatesAutoresizingMaskIntoConstraints = false
           
           let topStack = UIStackView(arrangedSubviews: [iconImageView, titleLabelTop])
           topStack.axis = .horizontal
           topStack.spacing = 6
           topStack.alignment = .center
           topStack.translatesAutoresizingMaskIntoConstraints = false
           view.addSubview(topStack)
           
           // Main Title: "Desires Come Alive in Sound"
           let mainTitleLabel = UILabel()
           mainTitleLabel.numberOfLines = 0
           mainTitleLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
           mainTitleLabel.translatesAutoresizingMaskIntoConstraints = false
           
           // Create attributed string to color some words pink
           let text = "*Share* your aura. *Discover* others."
        let attributed = text.makeAttributedString()
           
           mainTitleLabel.attributedText = NSAttributedString(attributed)
         
           
           view.addSubview(mainTitleLabel)
           
           // Subtitle
           let subtitleLabel = UILabel()
           subtitleLabel.text = "Be part of a community where every vibe matters."
           subtitleLabel.textColor = .lightGray
           subtitleLabel.font = UIFont.systemFont(ofSize: 16)
           subtitleLabel.numberOfLines = 0
           subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
           view.addSubview(subtitleLabel)
           
           // Constraints
           NSLayoutConstraint.activate([
               topStack.topAnchor.constraint(equalTo: bottomBaseView.safeAreaLayoutGuide.topAnchor, constant: 40),
               topStack.leadingAnchor.constraint(equalTo: bottomBaseView.leadingAnchor, constant: 20),
               
               mainTitleLabel.topAnchor.constraint(equalTo: topStack.bottomAnchor, constant: 16),
               mainTitleLabel.leadingAnchor.constraint(equalTo: bottomBaseView.leadingAnchor, constant: 20),
               mainTitleLabel.trailingAnchor.constraint(equalTo: bottomBaseView.trailingAnchor, constant: -20),
               
               subtitleLabel.topAnchor.constraint(equalTo: mainTitleLabel.bottomAnchor, constant: 12),
               subtitleLabel.leadingAnchor.constraint(equalTo: bottomBaseView.leadingAnchor, constant: 20),
               subtitleLabel.trailingAnchor.constraint(equalTo: bottomBaseView.trailingAnchor, constant: -50)
           ])
       }
    func setBottomBaseView() {
        view.addSubview(bottomBaseView)
        
        NSLayoutConstraint.activate([
            // Put it overlapping the bottom 20-30% of carousel
            bottomBaseView.topAnchor.constraint(equalTo: welcome_background_carousel.bottomAnchor, constant: -60),
            bottomBaseView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBaseView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBaseView.bottomAnchor.constraint(equalTo:view.bottomAnchor)
        ])
        // Create a fade at the top
        
        view.addSubview(gradientView)
        gradientView.applyStyle(.custom([
               UIColor.clear.cgColor,
               UIColor.black.withAlphaComponent(0.3).cgColor,
               UIColor.black.withAlphaComponent(0.9).cgColor
           ], [0.0, 0.4, 1.0]))
        NSLayoutConstraint.activate([
               gradientView.topAnchor.constraint(equalTo: bottomBaseView.topAnchor,constant: -40),
               gradientView.leadingAnchor.constraint(equalTo: bottomBaseView.leadingAnchor),
               gradientView.trailingAnchor.constraint(equalTo: bottomBaseView.trailingAnchor),
               gradientView.heightAnchor.constraint(equalToConstant: 40) // Adjust as needed
           ])
    }
    
    func setImageToBackground(){
       
        view.addSubview(welcome_background_carousel)
        view.sendSubviewToBack(welcome_background_carousel)

        // Full width, 60% height
        welcome_background_carousel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            welcome_background_carousel.topAnchor.constraint(equalTo: view.topAnchor), // ignore safe area
            welcome_background_carousel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            welcome_background_carousel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            welcome_background_carousel.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.6)
        ])
    }

    private func setupPageControl() {
        customPageControl.numberOfPages = welcome_background_carousel.images.count
           customPageControl.currentPage = 0
           
        view.addSubview(customPageControl)
           customPageControl.translatesAutoresizingMaskIntoConstraints = false
           NSLayoutConstraint.activate([
            customPageControl.topAnchor.constraint(equalTo: bottomBaseView.topAnchor, constant: 10),
            customPageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
           ])
       }
   
}


#Preview {
    WelcomeViewController()
}
