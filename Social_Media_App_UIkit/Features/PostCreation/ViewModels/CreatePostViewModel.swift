//
//  CreatePostViewMode.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 12/9/25.
//

import UIKit
import Combine

class CreatePostViewModel:ObservableObject{
    weak var coordinator:CreatePostDelegate?
    var selectedImage:UIImage?
   @Published var isLoading:Bool = false
    @Published private(set) var errorMessage: String? = nil
    
    let postService = PostActionService()
    
    func createPost(caption:String,location:String?) async{
        guard !isLoading else{return}
      
        if let image = self.selectedImage{
            isLoading = true
                do{
                   let createdPost = try await   postService.createPost(caption: caption, image: image , location: location)
                  print("Create \(createdPost)")
                    coordinator?.finishedCreatingPost(post: createdPost)
                }catch{
                    errorMessage = error.localizedDescription
                }
            isLoading = false
            
        }
    }
    func tappedCancel(){
        self.isLoading = false
        self.coordinator?.tappedCancelCreate()
    }
}
