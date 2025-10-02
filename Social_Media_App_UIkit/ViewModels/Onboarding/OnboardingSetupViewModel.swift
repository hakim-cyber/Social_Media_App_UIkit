//
//  OnboardingSetupViewModel.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 9/29/25.
//

import UIKit
import Combine

class OnboardingSetupViewModel{
    weak var delegate: OnboardingSetupViewModelDelegate?
   var image: UIImage?
    var userName:String = ""
    var name:String = ""
    var bio:String = ""
    let userNameValidator:UsernameValidator = .init()
    @Published var error:String? = nil
    
    func checkUsername(userName:String)async->Bool{
      let (valid,error) = await userNameValidator.validate(userName)
        if !valid{
            self.error = error
        }else{
            self.error = nil
        }
        return valid
    }
    func checkName(name:String){
        
    }
    func setProfileImage(_ image: UIImage?) {
        self.image = image
        delegate?.selectedProfileImage()
    }
    func setInfo(userName: String, name: String, bio: String) {
        self.userName = userName
        self.name = name
        self.bio = bio
       
    }
}
