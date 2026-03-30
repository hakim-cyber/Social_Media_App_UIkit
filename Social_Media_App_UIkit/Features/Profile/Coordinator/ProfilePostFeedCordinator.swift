//
//  ProfilePostFeedCordinator.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 12/27/25.
//

import Foundation

import UIKit
import Supabase
import Combine
final class ProfilePostFeedCordinator: NavigationCoordinator,ParentCoordinator, ChildCoordinator {

    // MARK: - ParentCoordinator
    var childCoordinators: [Coordinator] = []

    // MARK: - ChildCoordinator
    weak var parentCoordinator: ParentCoordinator?

    // MARK: - Coordinator
    var navigationController: UINavigationController

    private let viewModel: ProfileViewModel
    private let seletedPost: Post
    private var cancellables = Set<AnyCancellable>()
    private weak var commentsNavController: UINavigationController?
    private var commentRouteCancellable: AnyCancellable?
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
        bindPostRoutes()
        let vc = ProfilePostFeedViewController(selectedPost: seletedPost, vm: viewModel)

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
    private func bindPostRoutes() {
        cancellables.removeAll()
        viewModel.postRoute
            .receive(on: DispatchQueue.main)
            .sink { [weak self] route in
                self?.handle(route)
            }
            .store(in: &cancellables)
    }
}

extension ProfilePostFeedCordinator {
    private func handle(_ route: ProfilePostRoute) {
        switch route {
        case .openProfile(let author):
            showProfile(author: author)
        case .showPostMore(let post):
            showPostMore(post)
        case .showComments(let post):
            showComments(for: post)
        }
    }

    private func showPostMore(_ post: Post) {
        MoreSheetPresenter.showPost(
            post,
            from: self.navigationController,
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

    private func showComments(for post: Post) {
        let viewModel = CommentViewModel(postId: post.id,
                                        service: CommentService(),
                                        commentsCount: post.commentCount)
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
}

extension ProfilePostFeedCordinator {
    func childDidFinish(_ child: Coordinator?) {
        guard let child else{return}
        removeChild(child)
    }
}

extension ProfilePostFeedCordinator{
    private func bindCommentRoutes(_ viewModel: CommentViewModel) {
        commentRouteCancellable = viewModel.route
            .receive(on: DispatchQueue.main)
            .sink { [weak self] route in
                switch route {
                case .openProfile(let author):
                    self?.showProfile(author: author)
                }
            }
    }

    private func dismissPresentedIfNeeded(animated: Bool = true, completion: @escaping () -> Void) {
        // If you keep an explicit ref (recommended)
        if let nav = commentsNavController {
            commentsNavController = nil
            commentRouteCancellable = nil
            nav.dismiss(animated: animated, completion: completion)
            return
        }

        // Fallback: dismiss whatever is presented from the feed nav
        if let presented = navigationController.presentedViewController {
            commentRouteCancellable = nil
            presented.dismiss(animated: animated, completion: completion)
            return
        }

        completion()
    }
}
