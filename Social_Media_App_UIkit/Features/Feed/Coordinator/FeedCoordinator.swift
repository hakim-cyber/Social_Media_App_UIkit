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

    private let dependencies: MainFeedDependencies
    private let profileDependencies: MainProfileDependencies
    private lazy var viewModel = FeedViewModel(
        service: dependencies.feedService,
        realtime: FeedRealtime(client: dependencies.supabaseClient),
        translationController: PostTranslationController(service: dependencies.translationService),
        userService: dependencies.userService,
        postService: dependencies.postActionService
    )

    private weak var commentsNavController: UINavigationController?

    init(
        navigationController: UINavigationController,
        dependencies: MainFeedDependencies,
        profileDependencies: MainProfileDependencies
    ) {
        self.navigationController = navigationController
        self.dependencies = dependencies
        self.profileDependencies = profileDependencies
    }

    func start(animated: Bool) {
        viewModel.onRoute = { [weak self] route in
            DispatchQueue.main.async {
                switch route {
                case .openProfile(let userId):
                    self?.showProfile(id: userId)
                case .showPostMore(let post):
                    self?.postCellDidTapMore(post)
                case .showComments(let post):
                    self?.postCellDidTapComment(post)
                }
            }
        }
        let vc = PostFeedViewController(vm: viewModel)


        navigationController.setViewControllers([vc], animated: animated)
    }

    func showProfile(id: UUID) {
        dismissPresentedIfNeeded { [weak self] in
            guard let self else { return }

            let currentId = self.dependencies.sessionStore.currentUser?.id

            if currentId == id,
               let main = self.parentCoordinator as? MainCoordinator {
                main.switchToMyProfile()
                return
            }

            let coord = ProfileCoordinator(
                navigationController: self.navigationController,
                dependencies: self.profileDependencies,
                feedDependencies: self.dependencies,
                target: .user(id: id)
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

extension FeedCoordinator {
    func postCellDidTapMore(_ post: Post) {
        MoreSheetPresenter.showPost(
            post,
            from: self.navigationController,
            canDeletePost: post.author.id == dependencies.sessionStore.currentUser?.id,
            onSave: {[weak self] in
                self?.viewModel.toggleSave(for: post.id, desiredState: !post.isSaved)
            },
            onCopy: {/*[weak self] in*/
               // for now like this later change so it gives real url

                UIPasteboard.general.string = post.author.username
            },
            onReport: {

            },
            onDelete: {[weak self] in
                self?.viewModel.deletePost(post: post.id)
            }
        )

    }




    func postCellDidTapComment(_ post: Post) {
        let viewModel = CommentViewModel(
            postId: post.id,
            service: dependencies.commentService,
            commentsCount: post.commentCount,
            userService: dependencies.userService,
            translationService: dependencies.translationService,
            sessionStore: dependencies.sessionStore
        )
        bindCommentRoutes(viewModel)

        let commentsVC = PostCommentViewController(vm: viewModel)
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
        showProfile(id: post.author.id)
    }

}

extension FeedCoordinator {
    func childDidFinish(_ child: Coordinator?) {
        guard let child else{return}

        removeChild(child)
    }
}

extension FeedCoordinator{
    private func bindCommentRoutes(_ viewModel: CommentViewModel) {
        viewModel.onRoute = { [weak self] route in
            DispatchQueue.main.async {
                switch route {
                case .openProfile(let author):
                    self?.showProfile(id: author.id)
                }
            }
        }
    }

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
