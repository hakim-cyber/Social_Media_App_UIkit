//
//  CommentCoordinator.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 12/25/25.
//

import Foundation
/*
 
 import UIKit
 import Supabase
 final class CommentCoordinator:NSObject,ParentCoordinator, ChildCoordinator {

     // MARK: - ParentCoordinator
     var childCoordinators: [Coordinator] = []

     // MARK: - ChildCoordinator
     weak var parentCoordinator: ParentCoordinator?

      var navigationController: UINavigationController?
    

     private let commentService: CommentService = .init()
  

     private var viewModel: CommentViewModel?
     let post:Post
    

     init(
         post:Post
     ) {
      
         self.post = post
     }

     func start(animated: Bool) {
         
         let viewModel = CommentViewModel(postId: post.id,
                                         service: CommentService(),
                                         commentsCount: post.commentCount)

         self.viewModel = viewModel
         let commentsVC = PostCommentViewController(vm: viewModel)
         commentsVC.coordinator = self
         let navController = UINavigationController(rootViewController: commentsVC)
         navController.modalPresentationStyle = .formSheet
         navController.presentationController?.delegate = self
         
         self.navigationController = navController

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
        
     }

     func showProfile(author:UserSummary){
      guard let navigationController else { return }
         if let currentUserId = UserSessionService.shared.currentUser?.id, currentUserId == author.id {
             let profileCoordinator = ProfileCoordinator(navigationController: navigationController, target: .me)
             profileCoordinator.parentCoordinator = self
             addChild(profileCoordinator)
             profileCoordinator.startPush(animated: true)
        }else{
            let profileCoordinator = ProfileCoordinator(navigationController: navigationController, target: .user(id: author.id))
            profileCoordinator.parentCoordinator = self
            addChild(profileCoordinator)
            profileCoordinator.startPush(animated: true)
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


 protocol CommentCoordinating: AnyObject {
     func commentCellDidTapMore(comment: PostComment)
     func commentCellDidTapAvatar(comment: PostComment)
 }

 extension CommentCoordinator: CommentCoordinating {
     func commentCellDidTapMore(comment: PostComment) {
        
     }
     func commentCellDidTapAvatar(comment: PostComment) {
         // go to profile
         showProfile(author: comment.author)
         print("Show Profile")
     }
 }

 extension CommentCoordinator:UIAdaptivePresentationControllerDelegate {
     func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
         coordinatorDidFinish()
     }
 }

 */
