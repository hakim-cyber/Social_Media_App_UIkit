//
//  ProfilePostFeedViewController.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 12/27/25.
//

import UIKit
import Foundation
import Combine

class ProfilePostFeedViewController: UIViewController {
    
    nonisolated enum Section: Hashable, Sendable {
        case main
    }

    private var cancellables = Set<AnyCancellable>()
    
    var dataSource: UITableViewDiffableDataSource<Section, Post>?
    let vm:ProfileViewModel
    let selectedPost:Post
    weak var coordinator: FeedCoordinating?
    
    private var pendingScrollPostId: UUID?
    private var didScrollToInitialPost = false
    private lazy var postFeedTableView: UITableView = {
        let tv = UITableView()
        tv.showsVerticalScrollIndicator = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = .clear
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = self.view.bounds.height / 1.45
        tv.separatorStyle = .none
        tv.register(PostFeedTableViewCell.self, forCellReuseIdentifier: PostFeedTableViewCell.reuseID)
        tv.allowsSelection = true
        tv.delegate = self
        
        return tv
    }()
    init(selectedPost:Post,vm:ProfileViewModel) {
        self.vm = vm
        self.selectedPost = selectedPost
        super.init(nibName: nil, bundle: nil)
        self.pendingScrollPostId = selectedPost.id
      
    }
   
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func setupNavBar() {
     
        switch self.vm.selectedTab {
        case .posts:
            setNavigationTitle(title: "Posts", subtitle: vm.profile?.username ?? ""  )
        case .liked:
            setNavigationTitle(title: "Liked Posts", subtitle: vm.profile?.username ?? ""  )
           
        case .saved:
            setNavigationTitle(title: "Saved Posts", subtitle: vm.profile?.username ?? ""  )
          
        }
    }
    func setNavigationTitle(title: String, subtitle: String) {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center

        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = .systemFont(ofSize: 12, weight: .regular)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.textAlignment = .center

        let stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 0

        navigationItem.titleView = stackView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setup()
        
       setupNavBar()
        configureDataSource()
        updateData(posts: vm.activePosts)
        bindToViewModel()
        Task { await vm.start() }
     
    }
    private func scrollToPendingPostIfNeeded() {
        guard !didScrollToInitialPost, let id = pendingScrollPostId else { return }
        didScrollToInitialPost = true
        pendingScrollPostId = nil

        guard let index = vm.activePosts.firstIndex(where: { $0.id == id }) else { return }
        let rows = postFeedTableView.numberOfRows(inSection: 0)
        guard index < rows else { return }

        let indexPath = IndexPath(row: index, section: 0)

        postFeedTableView.layoutIfNeeded()
        postFeedTableView.scrollToRow(at: indexPath, at: .middle, animated: false)
    }
    func setup() {
        self.view.backgroundColor = .systemBackground
        
        self.view.addSubview(postFeedTableView)
        NSLayoutConstraint.activate([
            postFeedTableView.topAnchor.constraint(equalTo: self.view.topAnchor),
            postFeedTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            postFeedTableView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            postFeedTableView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
   
    
    func returnToTopRow(){
        let indexPath = IndexPath(row: 0, section: 0)
        postFeedTableView.scrollToRow(at: indexPath, at: .top, animated: true)
    }
    
    
    private func toggleFooterSpinner(visible: Bool) {
        if visible {
            let spinner = UIActivityIndicatorView(style: .medium)
            spinner.startAnimating()
            spinner.frame = CGRect(x: 0, y: 0, width: postFeedTableView.bounds.width, height: 44)
            postFeedTableView.tableFooterView = spinner
        } else {
            postFeedTableView.tableFooterView = nil
        }
    }

    func bindToViewModel() {
        switch vm.selectedTab {
        case .posts:
            vm.$posts
                   .receive(on: DispatchQueue.main)
                   .sink { [weak self] newPosts in
                       guard let self else { return }
                       self.updateData(posts: newPosts)
                   }
                   .store(in: &cancellables)
            
        case .liked:
            vm.$likedPosts
                   .receive(on: DispatchQueue.main)
                   .sink { [weak self] newPosts in
                       guard let self else { return }
                       self.updateData(posts: newPosts)
                   }
                   .store(in: &cancellables)

              
        case .saved:
            vm.$savedPosts
                .receive(on: DispatchQueue.main)
                .sink { [weak self] newPosts in
                    guard let self else { return }
                    self.updateData(posts: newPosts)
                }
                .store(in: &cancellables)
        }
        vm.$postTranslations
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    guard let self else { return }
                    self.reconfigureVisibleTranslatedPosts()
                }
                .store(in: &cancellables)
    }
    private func reconfigureVisibleTranslatedPosts() {
        guard var snapshot = dataSource?.snapshot() else { return }

        let visibleIndexPaths = postFeedTableView.indexPathsForVisibleRows ?? []
        let visiblePosts: [Post] = visibleIndexPaths.compactMap { indexPath in
            dataSource?.itemIdentifier(for: indexPath)
        }

        // Only reconfigure those which have translation state
        let toReconfigure = visiblePosts.filter { vm.postTranslations[$0.id] != nil }

        guard !toReconfigure.isEmpty else { return }

        snapshot.reconfigureItems(toReconfigure)
        dataSource?.apply(snapshot, animatingDifferences: false)
    }
    func updateData(posts: [Post]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Post>()
        snapshot.appendSections([.main])
        snapshot.appendItems(posts, toSection: .main)
        DispatchQueue.main.async {
            self.dataSource?.apply(snapshot, animatingDifferences: false) { [weak self] in
                       guard let self else { return }
                       self.scrollToPendingPostIfNeeded()
                   }
        }
    }
  
    
    func configureDataSource() {
        dataSource = UITableViewDiffableDataSource<Section, Post>(
            tableView: postFeedTableView
        ) { [weak self] tableView, indexPath, post in
            let cell = tableView.dequeueReusableCell(
                withIdentifier: PostFeedTableViewCell.reuseID,
                for: indexPath
            ) as! PostFeedTableViewCell

            cell.delegate = self
            cell.configure(with: post, translation:self?.vm.postTranslations[post.id])
            return cell
        }
        postFeedTableView.dataSource = dataSource
    }
    
    
    
    
}

// MARK: - Scrolling → infinite load trigger
extension ProfilePostFeedViewController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let threshold = scrollView.contentSize.height - scrollView.bounds.height * 1.8
        if offsetY > threshold {
           
            vm.loadMoreIfNeeded()
        }
    }
}

extension ProfilePostFeedViewController: PostCellDelegate {
    func postCellDidTapTranslate(_ cell: PostFeedTableViewCell) {
        guard let post = cell.post else { return }
        print("did tap translate")
        self.vm.togglePostTranslation(postId: post.id, originalText: post.caption)
    }
    
    func postCellDidTapLike(_ cell: PostFeedTableViewCell) {
        guard let post = cell.post else { return }
        Task {
             vm.toggleLike(for: post.id, desiredState: !post.isLiked)
        }
    }

    func postCellDidTapAvatar(_ cell: PostFeedTableViewCell) {
        // push profile VC, using cell.post?.author
        guard let post = cell.post else { return }
        self.coordinator?.postCellDidTapAvatar(post)
        print("postCellDidTapAvatar")
    }

    func postCellDidTapMore(_ cell: PostFeedTableViewCell) {
        // action sheet etc.
        guard let post = cell.post else { return }
        self.coordinator?.postCellDidTapMore(post)
    }

    func postCellDidTapComment(_ cell: PostFeedTableViewCell) {
        // present comments screen
        guard let post = cell.post else { return }
        self.coordinator?.postCellDidTapComment(post)
    }

    func postCellDidTapSave(_ cell: PostFeedTableViewCell) {
        guard let post = cell.post else { return }
        Task {
             vm.toggleSave(for: post.id, desiredState: !post.isSaved)
        }
    }
}

#Preview {
    PostFeedViewController(vm:FeedViewModel(service: .init(), realtime: .init()))
}
