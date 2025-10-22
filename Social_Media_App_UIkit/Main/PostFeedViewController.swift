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
    
    init() {
        vm = FeedViewModel(service: FeedService(),realtime: FeedRealtime())
        super.init(nibName: nil, bundle: nil)
      
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setup()
        configureDataSource()
        bindToViewModel()
       
    }
    func setup() {
        self.view.backgroundColor = .systemBackground
        self.postFeedTableView.contentInset = UIEdgeInsets(top: 50, left: 0, bottom: 35, right: 0)
        
        // Add refresh control
           refreshControl.addTarget(self, action: #selector(handlePullToRefresh), for: .valueChanged)
           postFeedTableView.refreshControl = refreshControl
        
        self.view.addSubview(postFeedTableView)
        NSLayoutConstraint.activate([
            postFeedTableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            postFeedTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            postFeedTableView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            postFeedTableView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    @objc private func handlePullToRefresh() {
        Task { /*await vm.refresh()*/ }    // triggers your ViewModel’s newer fetch
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
            self.dataSource?.apply(snapshot, animatingDifferences: true)
        }
    }
  
    
    func configureDataSource() {
        dataSource = UITableViewDiffableDataSource<PostFeedSection, Post>(tableView: postFeedTableView, cellProvider: { (tableView: UITableView, indexPath: IndexPath, post: Post) in
            let cell = tableView.dequeueReusableCell(withIdentifier: PostFeedTableViewCell.reuseID, for: indexPath) as! PostFeedTableViewCell
            cell.selectionStyle = .none
            cell.userInteractionEnabledWhileDragging = true
            cell.isUserInteractionEnabled = true
            cell.backgroundColor = .clear
            cell.configure(with: post)
            return cell
        })
        postFeedTableView.dataSource = dataSource
    }
    
    
    
    
}

// MARK: - Scrolling → infinite load trigger
extension PostFeedViewController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let threshold = scrollView.contentSize.height - scrollView.bounds.height * 1.8
        if offsetY > threshold {
            let lastVisible = postFeedTableView.indexPathsForVisibleRows?.map(\.row).max() ?? 0
            Task {/* await vm.loadMoreIfNeeded(currentLastVisibleIndex: lastVisible)*/ }
        }
    }
}


#Preview {
    PostFeedViewController()
}
