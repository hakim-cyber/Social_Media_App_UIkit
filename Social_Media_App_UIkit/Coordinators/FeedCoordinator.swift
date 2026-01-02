//
//  FeedCoordinator.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 12/8/25.
//

import UIKit
import Supabase
final class FeedCoordinator: NavigationCoordinator,ParentCoordinator, ChildCoordinator {

    // MARK: - ParentCoordinator
    var childCoordinators: [Coordinator] = []

    // MARK: - ChildCoordinator
    weak var parentCoordinator: ParentCoordinator?

    // MARK: - Coordinator
    var navigationController: UINavigationController

    private let feedService: FeedService
    private let realtime: FeedRealtime

    private var viewModel: FeedViewModel?
    private var createPostCoordinator: CreatePostCoordinator?
    private weak var commentsNavController: UINavigationController?
    init(
        navigationController: UINavigationController,
        feedService: FeedService = .init(),
        realtime: FeedRealtime = .init()
    ) {
        self.navigationController = navigationController
        self.feedService = feedService
        self.realtime = realtime
    }

    func start(animated: Bool) {
        let vm = FeedViewModel(service: feedService, realtime: realtime)
        self.viewModel = vm

        let vc = PostFeedViewController(vm: vm)
        vc.coordinator = self   // via protocol

        navigationController.setViewControllers([vc], animated: animated)
    }

    func showProfile(author: UserSummary) {
        dismissPresentedIfNeeded { [weak self] in
            guard let self else { return }

            let currentId = UserSessionService.shared.currentUser?.id

            if currentId == author.id,
               let main = self.parentCoordinator as? MainCoordinator {
                main.switchToMyProfile()
                return
            }

            let coord = ProfileCoordinator(
                navigationController: self.navigationController,
                target: .user(id: author.id)
            )
            coord.parentCoordinator = self
            self.addChild(coord)
            coord.startPush(animated: true)
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

// what view needs to see
protocol FeedCoordinating: AnyObject {
    func postFeedDidRequestCreatePost(_ controller: PostFeedViewController)
    func postCellDidTapComment(_ post:Post)
    func postCellDidTapAvatar(_ post:Post)
    func postCellDidTapMore(_ post:Post)
}

extension FeedCoordinator: FeedCoordinating {
    func postCellDidTapMore(_ post: Post) {
        MoreSheetPresenter.showPost(
            post,
            from: self.navigationController,
            onSave: {
               
            },
            onCopy: {
               
            },
            onReport: {
              
            },
            onDelete: {
               
            }
        )

    }
    
  

    func postFeedDidRequestCreatePost(_ controller: PostFeedViewController) {
        let coord = CreatePostCoordinator(presenter: navigationController)
        coord.parentCoordinator = self

        addChild(coord)                 // ✅ important
        createPostCoordinator = coord   // optional strong ref

        coord.start(animated: true)
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

extension FeedCoordinator {
    func childDidFinish(_ child: Coordinator?) {
        guard let child else{return}
        if child === createPostCoordinator {
            createPostCoordinator = nil
        }
        removeChild(child)
    }
}


protocol CommentCoordinating: AnyObject {
    func commentCellDidTapDelete(comment: PostComment)
    func commentCellDidTapAvatar(comment: PostComment)
}

extension FeedCoordinator: CommentCoordinating {
    func commentCellDidTapDelete(comment: PostComment) {
       
    }
    func commentCellDidTapAvatar(comment: PostComment) {
        // go to profile
        showProfile(author: comment.author)
        print("Show Profile")
    }
}

extension FeedCoordinator{
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
