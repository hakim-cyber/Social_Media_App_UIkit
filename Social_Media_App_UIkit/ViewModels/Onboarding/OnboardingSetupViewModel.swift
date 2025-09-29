//
//  OnboardingSetupViewModel.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 9/29/25.
//

import UIKit


class OnboardingSetupViewModel{
    weak var delegate: OnboardingSetupViewModelDelegate?
   var image: UIImage?
    var userName:String = ""
    var name:String = ""
    var bio:String = ""
    
    func setProfileImage(_ image: UIImage?) {
        self.image = image
        delegate?.selectedProfileImage()
    }
}
