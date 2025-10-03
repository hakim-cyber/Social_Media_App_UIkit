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
    let profileService:ProfileService
    init(profileService:ProfileService){
        self.profileService = profileService
    }
   var image: UIImage?
    var userName:String = ""
    var name:String = ""
    var bio:String = ""
    let userNameValidator:UsernameValidator = .init()
    @Published var error:String? = nil
    @Published var loading:Bool = false
    
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
       
        createUserProfile()
    }
    func createUserProfile(){
        Task{
            do{
                self.loading = true
             let newProfile = try await profileService.createNewProfile(username: userName, fullName: name, bio: bio, avatarImage: image)
                delegate?.finishedInfoSetup()
                self.loading = false
                print("nice finished creation \(newProfile)")
            }catch{
                self.error = error.localizedDescription
                self.loading = false
            }
          
        }
    }
}
