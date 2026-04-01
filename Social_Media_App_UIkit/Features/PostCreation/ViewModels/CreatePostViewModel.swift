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

@MainActor
final class CreatePostViewModel: ObservableObject {
    var selectedImage:UIImage?
    @Published private(set) var selectedLocation: String?
    @Published var isLoading:Bool = false
    @Published private(set) var errorMessage: String? = nil

    var onRoute: ((CreatePostRoute) -> Void)?
    private let postService: any PostActionServicing

    init(postService: any PostActionServicing) {
        self.postService = postService
    }

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
            onRoute?(.finished(createdPost))
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func tappedCancel(){
        onRoute?(.cancel)
    }

    func tappedLocation(){
        onRoute?(.showLocationPicker)
    }

    func setSelectedLocation(_ location: String) {
        selectedLocation = location
    }

    func clearLocation() {
        selectedLocation = nil
    }
}
