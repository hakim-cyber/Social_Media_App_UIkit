//
//  EditProfileViewModel.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 12/26/25.
//

import UIKit
import Combine

class EditProfileViewModel{
    var onProfileUpdated: ((UserProfile) -> Void)?
    let profileService:ProfileService
    init(profileService:ProfileService){
        self.profileService = profileService
    }
    @Published  var image: UIImage?
    var userName:String = ""
    var name:String = ""
    var bio:String = ""
    let userNameValidator:UsernameValidator = .init()
    @Published var error:String? = nil
    @Published var loading:Bool = false
    
    func configure(with profile: UserProfile) {
            self.userName = profile.username
            self.name = profile.full_name
            self.bio = profile.bio ?? ""
        Task{
            do {
                if let stringUrl = profile.avatar_url{
                    image = try await loadImage(from:stringUrl)
                }
              
            } catch {
                print("Failed to load avatar image:", error)
            }
        }
            // image stays nil until user picks new one
        }
    func loadImage(from urlString: String) async throws -> UIImage {
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        guard let image = UIImage(data: data) else {
            throw URLError(.cannotDecodeContentData)
        }

        return image
    }
    func checkUsername(userName:String)async->Bool{
      let (valid,error) = await userNameValidator.validate(userName)
        if !valid{
            self.error = error
        }else{
            self.error = nil
        }
        return valid
    }
    
    func saveUserProfile(image:UIImage?,userName:String,name:String,bio:String,completion:@escaping (Bool) -> Void){
        Task{
            do{
                self.loading = true
             let newProfile = try await profileService.updateProfile(username: userName, fullName: name, bio: bio, avatarImage: image)
               
                self.loading = false
                print("nice updating \(newProfile)")
                self.onProfileUpdated?(newProfile)
                completion(true)
                self.image = image
                self.userName = userName
                self.name = name
                self.bio = bio
                
            }catch{
                self.error = error.localizedDescription
                self.loading = false
                completion(false)
            }
          
        }
    }
}
