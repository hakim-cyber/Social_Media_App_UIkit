//
//  CreatePostViewMode.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 12/9/25.
//

import UIKit
import Combine


enum CreatePostRoute {
    case cancel
    case showLocationPicker
    case finished(Post)
}

final class CreatePostViewModel: ObservableObject {
    var selectedImage:UIImage?
    @Published private(set) var selectedLocation: String?
    @Published var isLoading:Bool = false
    @Published private(set) var errorMessage: String? = nil

    let route = PassthroughSubject<CreatePostRoute, Never>()
    private let postService = PostActionService()

    func createPost(caption: String) async {
        guard !isLoading else { return }

        guard let image = selectedImage else {
            errorMessage = "Please select an image."
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let createdPost = try await postService.createPost(
                caption: caption,
                image: image,
                location: selectedLocation
            )
            route.send(.finished(createdPost))
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func tappedCancel(){
        self.route.send(.cancel)
    }

    func tappedLocation(){
        self.route.send(.showLocationPicker)
    }

    func setSelectedLocation(_ location: String) {
        selectedLocation = location
    }

    func clearLocation() {
        selectedLocation = nil
    }
}
