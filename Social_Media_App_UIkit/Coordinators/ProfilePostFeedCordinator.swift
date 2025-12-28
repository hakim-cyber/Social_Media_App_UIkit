//
//  ProfilePostFeedCordinator.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 12/27/25.
//

import Foundation

import UIKit
import Supabase
final class ProfilePostFeedCordinator: NavigationCoordinator,ParentCoordinator, ChildCoordinator {

    // MARK: - ParentCoordinator
    var childCoordinators: [Coordinator] = []

    // MARK: - ChildCoordinator
    weak var parentCoordinator: ParentCoordinator?

    // MARK: - Coordinator
    var navigationController: UINavigationController

    private let viewModel: ProfileViewModel
    private let seletedPost: Post
    private var createPostCoordinator: CreatePostCoordinator?
    private weak var commentsNavController: UINavigationController?
    init(
        navigationController: UINavigationController,
        viewModel:ProfileViewModel,
        selectedPost:Post
    ) {
        self.navigationController = navigationController
        self.viewModel = viewModel
        self.seletedPost = selectedPost
    }

    func start(animated: Bool) {
        let vc = ProfilePostFeedViewController(selectedPost: seletedPost, vm: viewModel)
        vc.coordinator = self
        
        navigationController.pushViewController(vc, animated: true)
    }

    func showProfile(author: UserSummary) {
        dismissPresentedIfNeeded { [weak self] in
            guard let self else { return }

            let currentId = UserSessionService.shared.currentUser?.id

            if currentId == author.id{
               let coord = ProfileCoordinator(
                   navigationController: self.navigationController,
                   target: .me
               )
               coord.parentCoordinator = self
               self.addChild(coord)
               coord.startPush(animated: true)
            }else{
                
                let coord = ProfileCoordinator(
                    navigationController: self.navigationController,
                    target: .user(id: author.id)
                )
                coord.parentCoordinator = self
                self.addChild(coord)
                coord.startPush(animated: true)
            }
        }
    }
    deinit {
        print("FeedCoordinator deinit")
    }

    func coordinatorDidFinish() {
        print("FeedCoordinator finished")
        parentCoordinator?.childDidFinish(self)
    }
}

extension ProfilePostFeedCordinator: FeedCoordinating {
    func postFeedDidRequestCreatePost(_ controller: PostFeedViewController) {
    
    }
    
    func postCellDidTapComment(_ post: Post) {
        let viewModel = CommentViewModel(postId: post.id,
                                        service: CommentService(),
                                        commentsCount: post.commentCount)

        let commentsVC = PostCommentViewController(vm: viewModel)
        commentsVC.coordinator = self
        let navController = UINavigationController(rootViewController: commentsVC)
        navController.modalPresentationStyle = .formSheet
      
        commentsNavController = navController
        if let sheet = navController.sheetPresentationController {
            sheet.detents = [
                .custom(identifier: .medium) { ctx in
                    ctx.maximumDetentValue * 0.7   // 👈 try 0.9–0.95
                },
                .large()
            ]
            sheet.selectedDetentIdentifier = .medium
            sheet.prefersGrabberVisible = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = true

            // These two are basically iPad-ish behaviors; keep or remove, but they won't "remove bottom space" on iPhone.
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true

            sheet.largestUndimmedDetentIdentifier = .medium
        }

        navigationController.present(navController, animated: true)
    }
    
    func postCellDidTapAvatar(_ post: Post) {
        showProfile(author: post.author)
    }
    
}

extension ProfilePostFeedCordinator {
    func childDidFinish(_ child: Coordinator?) {
        guard let child else{return}
        if child === createPostCoordinator {
            createPostCoordinator = nil
        }
        removeChild(child)
    }
}


extension ProfilePostFeedCordinator: CommentCoordinating {
    func commentCellDidTapMore(comment: PostComment) {
       
    }
    func commentCellDidTapAvatar(comment: PostComment) {
        // go to profile
        showProfile(author: comment.author)
        print("Show Profile")
    }
}

extension ProfilePostFeedCordinator{
    private func dismissPresentedIfNeeded(animated: Bool = true, completion: @escaping () -> Void) {
        // If you keep an explicit ref (recommended)
        if let nav = commentsNavController {
            commentsNavController = nil
            nav.dismiss(animated: animated, completion: completion)
            return
        }

        // Fallback: dismiss whatever is presented from the feed nav
        if let presented = navigationController.presentedViewController {
            presented.dismiss(animated: animated, completion: completion)
            return
        }

        completion()
    }
}
