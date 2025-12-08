//
//  FeedCoordinator.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 12/8/25.
//

import UIKit
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
}

extension FeedCoordinator: FeedCoordinating {
  

    func postFeedDidRequestCreatePost(_ controller: PostFeedViewController) {
        let coord = CreatePostCoordinator(presenter: navigationController)
        coord.parentCoordinator = self

        addChild(coord)                 // ✅ important
        createPostCoordinator = coord   // optional strong ref

        coord.start(animated: true)
    }
    func postCellDidTapComment(_ post:Post) {
        let commentVC = PostCommentViewController(post: post)
        self.navigationController.present(commentVC, animated: true)
    }
    func postCellDidTapAvatar(_ post: Post) {
        
    }
    
}

extension FeedCoordinator {
    func childDidFinish(_ child: Coordinator?) {
        if child === createPostCoordinator {
            createPostCoordinator = nil
        }
    }
}
