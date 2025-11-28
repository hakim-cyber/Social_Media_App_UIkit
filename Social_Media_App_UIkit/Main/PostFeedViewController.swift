//
//  File.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 10/19/25.
//
import UIKit
import Foundation
import Combine

nonisolated enum PostFeedSection: Hashable, Sendable {
    case main
}

class PostFeedViewController: UIViewController {
    
    private var cancellables = Set<AnyCancellable>()
    
    var dataSource: UITableViewDiffableDataSource<PostFeedSection, Post>?
    let vm:FeedViewModel
    
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
    
    // Pull-to-refresh
    private let refreshControl = UIRefreshControl()
    private let bufferedBannerView = BufferedPostsBanner()
    private var isBannerVisible = false
    init() {
        vm = FeedViewModel(service: FeedService(),realtime: FeedRealtime())
        super.init(nibName: nil, bundle: nil)
        
      
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func setupNavBar() {
        // Cancel button
        let cancelButton = UIBarButtonItem(
            title: "Create",
            style: .plain,
            target: self,
            action: #selector(showCreate)
        )

        
        // Apply electric purple tint
        let electricPurple = UIColor.electricPurple
        cancelButton.tintColor = electricPurple
        

        navigationItem.leftBarButtonItem = cancelButton
       
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setup()
        
       setupNavBar()
        setupBufferBanner()
        configureDataSource()
        
        bindToViewModel()
        Task { await vm.start() }
     
    }
    func setup() {
        self.view.backgroundColor = .systemBackground
        self.postFeedTableView.contentInset = UIEdgeInsets(top: 50, left: 0, bottom: 35, right: 0)
       
        // Add refresh control
           refreshControl.addTarget(self, action: #selector(handlePullToRefresh), for: .valueChanged)
           postFeedTableView.refreshControl = refreshControl
        
        self.view.addSubview(postFeedTableView)
        NSLayoutConstraint.activate([
            postFeedTableView.topAnchor.constraint(equalTo: self.view.topAnchor),
            postFeedTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            postFeedTableView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            postFeedTableView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    func setupBufferBanner(){
        self.view.addSubview(bufferedBannerView)
        self.view.bringSubviewToFront(bufferedBannerView)
        self.bufferedBannerView.isHidden = false
        NSLayoutConstraint.activate([
            bufferedBannerView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            bufferedBannerView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            bufferedBannerView.heightAnchor.constraint(equalToConstant: 40),
            
            bufferedBannerView.widthAnchor.constraint(equalToConstant: 110)
        ])
        bufferedBannerView.isHidden = true
           bufferedBannerView.alpha = 0
        bufferedBannerView.onTap = { [weak self] in
            self?.tappedBanner()
        }
    }
    private func updateNewPostsBanner(count: Int) {
        if count > 0 {
            showBanner(with: count)
        } else {
            hideBanner()
        }
    }
    private func hideBanner() {
        guard isBannerVisible else { return }
        isBannerVisible = false

        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            options: [.curveEaseIn],
            animations: {
                self.bufferedBannerView.alpha = 0
                self.bufferedBannerView.transform =
                    CGAffineTransform(translationX: 0, y: -10)
            },
            completion: { _ in
                self.bufferedBannerView.isHidden = true
                self.bufferedBannerView.transform = .identity
            }
        )
    }
    private func showBanner(with count: Int) {
        bufferedBannerView.configure(count: count)

        
        guard !isBannerVisible else { return }
        isBannerVisible = true

        // Start slightly above + transparent
        bufferedBannerView.isHidden = false
        bufferedBannerView.alpha = 0
        bufferedBannerView.transform = CGAffineTransform(translationX: 0, y: -10)

        UIView.animate(
            withDuration: 0.25,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.8,
            options: [.curveEaseOut],
            animations: {
                self.bufferedBannerView.alpha = 1
                self.bufferedBannerView.transform = .identity
            },
            completion: nil
        )
    }
     private func tappedBanner() {
         print("vuffer")
         vm.revealBufferedNew()
         self.hideBanner()
         returnToTopRow()
    }
   
    @objc private func handlePullToRefresh() {
        Task {
            await vm.refresh()
            returnToTopRow()
        }
        
    }
    @objc private func showCreate() {
        self.navigationController?.pushViewController(PostCreationViewController(), animated: true)
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
        vm.$posts
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] posts in
                        self?.updateData(posts: posts)
                    }
                    .store(in: &cancellables)
        
        
        vm.$isRefreshing
                .removeDuplicates()
                .receive(on: DispatchQueue.main)
                .sink { [weak self] refreshing in
                    if !refreshing { self?.refreshControl.endRefreshing() }
                }
                .store(in: &cancellables)
        
        
        // 4) Optional loading-more spinner (footer)
        vm.$isLoadingMore
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] loading in
                self?.toggleFooterSpinner(visible: loading)
            }
            .store(in: &cancellables)
        
        vm.$bufferedNewCount
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] count in
                       self?.updateNewPostsBanner(count: count)
                    }
                    .store(in: &cancellables)
        
        // 5) Errors → toast/alert
                vm.$errorMessage
                    .compactMap { $0 }
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] msg in
                        self?.showToast(msg)
                    }
                    .store(in: &cancellables)

    }
   
    func updateData(posts: [Post]) {
        var snapshot = NSDiffableDataSourceSnapshot<PostFeedSection, Post>()
        snapshot.appendSections([.main])
        snapshot.appendItems(posts, toSection: .main)
        DispatchQueue.main.async {
            self.dataSource?.apply(snapshot, animatingDifferences: false)
        }
    }
  
    
    func configureDataSource() {
        dataSource = UITableViewDiffableDataSource<PostFeedSection, Post>(
            tableView: postFeedTableView
        ) { [weak self] tableView, indexPath, post in
            let cell = tableView.dequeueReusableCell(
                withIdentifier: PostFeedTableViewCell.reuseID,
                for: indexPath
            ) as! PostFeedTableViewCell

            cell.delegate = self
            cell.configure(with: post)
            return cell
        }
        postFeedTableView.dataSource = dataSource
    }
    
    
    
    
}

// MARK: - Scrolling → infinite load trigger
extension PostFeedViewController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let threshold = scrollView.contentSize.height - scrollView.bounds.height * 1.8
        if offsetY > threshold {
           
            Task {await vm.loadMore() }
        }
    }
}

extension PostFeedViewController: PostCellDelegate {
    func postCellDidTapLike(_ cell: PostFeedTableViewCell) {
        guard let post = cell.post else { return }
        Task {
             vm.toggleLike(for: post.id, desiredState: !post.isLiked)
        }
    }

    func postCellDidTapAvatar(_ cell: PostFeedTableViewCell) {
        // push profile VC, using cell.post?.author
    }

    func postCellDidTapMore(_ cell: PostFeedTableViewCell) {
        // action sheet etc.
    }

    func postCellDidTapComment(_ cell: PostFeedTableViewCell) {
        // present comments screen
    }

    func postCellDidTapSave(_ cell: PostFeedTableViewCell) {
        guard let post = cell.post else { return }
        Task {
             vm.toggleSave(for: post.id, desiredState: !post.isSaved)
        }
    }
}

#Preview {
    PostFeedViewController()
}
