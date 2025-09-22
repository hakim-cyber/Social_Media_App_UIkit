//
//  SlideToUnlockButton.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 9/22/25.
//

import Foundation

import UIKit

class SlideToUnlockView: UIView {

    // MARK: - Subviews
    private let trackView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.glassBackground
        
        return view
    }()

    private let sliderView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.electricPurple
       
        return view
    }()
    private let sliderImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "chevron.right",withConfiguration: UIImage.SymbolConfiguration(weight: .medium)))
        imageView.tintColor = .white
        return imageView
    }()
    private let trackImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "chevron.forward.2"))
        imageView.tintColor = .secondaryLabel
        return imageView
    }()

    private let label: UILabel = {
        let lbl = UILabel()
        lbl.text = "Slide to Unlock"
        lbl.textColor = .secondaryLabel
        lbl.textAlignment = .center
        lbl.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return lbl
    }()

    // MARK: - Properties
    private var sliderLeadingConstraint: NSLayoutConstraint!
    private var trackLeadingConstraint: NSLayoutConstraint!
    private var panStartX: CGFloat = 0
    var onUnlock: (() -> Void)? // callback when fully unlocked

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupGesture()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        setupGesture()
    }

    // MARK: - Setup
    private func setupViews() {
        addSubview(trackView)
        addSubview(label)
        addSubview(sliderView)
        addSubview(sliderImageView)
        addSubview(trackImageView)

        trackView.translatesAutoresizingMaskIntoConstraints = false
        sliderView.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        sliderImageView.translatesAutoresizingMaskIntoConstraints = false
        trackImageView.translatesAutoresizingMaskIntoConstraints = false
       
        NSLayoutConstraint.activate([
            self.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 0.15),
            trackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            trackView.topAnchor.constraint(equalTo: topAnchor),
            trackView.bottomAnchor.constraint(equalTo: bottomAnchor),

            label.centerXAnchor.constraint(equalTo: trackView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: trackView.centerYAnchor),
            label.widthAnchor.constraint(equalTo: trackView.widthAnchor),
            label.heightAnchor.constraint(equalTo: trackView.heightAnchor),

        
            sliderView.centerYAnchor.constraint(equalTo: centerYAnchor),
            sliderView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.15),
            sliderView.heightAnchor.constraint(equalTo: heightAnchor),
            
            sliderImageView.heightAnchor.constraint(equalTo: sliderView.heightAnchor,multiplier: 0.4),
            sliderImageView.widthAnchor.constraint(equalTo: sliderView.heightAnchor,multiplier: 0.3),
            sliderImageView.centerXAnchor.constraint(equalTo: sliderView.centerXAnchor),
            sliderImageView.centerYAnchor.constraint(equalTo: sliderView.centerYAnchor),
            
            trackImageView.centerYAnchor.constraint(equalTo: trackView.centerYAnchor),
            trackImageView.trailingAnchor.constraint(equalTo: trackView.trailingAnchor, constant: -10),
            trackImageView.heightAnchor.constraint(equalTo: sliderView.heightAnchor,multiplier: 0.42),
            trackImageView.widthAnchor.constraint(equalTo: sliderView.heightAnchor,multiplier: 0.5),
            
            
        ])
       

        sliderLeadingConstraint = sliderView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0)
        trackLeadingConstraint =   trackView.leadingAnchor.constraint(equalTo: leadingAnchor,constant: 0)
        sliderLeadingConstraint.isActive = true
        trackLeadingConstraint.isActive = true
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        sliderView.layer.cornerRadius = bounds.width * 0.15 / 2
        trackView.layer.cornerRadius = bounds.width * 0.15 / 2
        label.startShimmering(reverse: false)
        trackImageView.startShimmering(reverse: false)
    }
    private func setupGesture() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        sliderView.addGestureRecognizer(pan)
    }

    // MARK: - Gesture
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)

        switch gesture.state {
        case .began:
            panStartX = sliderLeadingConstraint.constant
            
        case .changed:
            let newX = max(0, min(bounds.width - sliderView.bounds.width, panStartX + translation.x))
            sliderLeadingConstraint.constant = newX
            trackLeadingConstraint.constant = newX
          
            // Calculate overlap as a fraction of slider over label
               let sliderCenterX = sliderView.frame.midX
               let labelStart = label.frame.minX
               let labelEnd = label.frame.maxX

               if sliderCenterX >= labelStart && sliderCenterX <= labelEnd {
                   // slider is overlapping label
                   let overlapFraction = (sliderCenterX - labelStart) / (labelEnd - labelStart)
                   let fadeFactor: CGFloat = 4.0
                   let alpha = max(0, 1 - overlapFraction * fadeFactor)// makes fading faster
                   label.alpha = alpha
                   trackImageView.alpha = alpha// fades from 1 to 0
               } else if sliderCenterX < labelStart {
                   label.alpha = 1
                   trackImageView.alpha  = 1
               } else {
                   label.alpha = 0
                   trackImageView.alpha = 0
               }
        case .ended, .cancelled:
            if sliderLeadingConstraint.constant >= bounds.width - sliderView.bounds.width - 5 {
                // Fully unlocked
                onUnlock?()
                let impactMed = UIImpactFeedbackGenerator(style: .heavy)
                    impactMed.impactOccurred()
                resetSlider()
                
            } else {
                // Animate back
                resetSlider()
            }
           
        default:
            break
        }
    }

    private func resetSlider() {
        UIView.animate(withDuration: 0.3) {
            self.sliderLeadingConstraint.constant = 0
            self.trackLeadingConstraint.constant = 0
            self.label.alpha = 1
            self.trackImageView.alpha = 1
            self.layoutIfNeeded()
        }
    }
}
