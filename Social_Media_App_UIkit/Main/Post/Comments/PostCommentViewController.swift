//
//  PostCommentViewController.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 12/4/25.
//


import UIKit
import Foundation
import Combine

nonisolated enum CommentSection: Hashable, Sendable {
    case main
}

class PostCommentViewController: UIViewController {
    
    private var cancellables = Set<AnyCancellable>()
    
    var dataSource: UITableViewDiffableDataSource<CommentSection, PostComment>?
    let vm:CommentViewModel

    private lazy var postCommentTableView: UITableView = {
        let tv = UITableView()
        tv.showsVerticalScrollIndicator = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = .clear
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = self.view.bounds.height / 3.45
        tv.separatorStyle = .none
        tv.register(PostCommentTableViewCell.self, forCellReuseIdentifier: PostCommentTableViewCell.reuseID)
        tv.allowsSelection = true
        tv.delegate = self
      
        return tv
    }()
    
    // Pull-to-refresh
   
    init(post:Post,) {
        vm = CommentViewModel(postId: post.id, service: CommentService(), commentsCount: post.commentCount)
        super.init(nibName: nil, bundle: nil)
        
      
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func setupNavBar() {
        self.modalPresentationStyle = .automatic
       
      
        if let sheet = sheetPresentationController {
                // 1) Start at half-screen (medium)
                // 2) Allow drag up to full-screen (large)
            sheet.detents = [
                    .custom(identifier: .medium) { context in
                     
                        return context.maximumDetentValue * 0.8   // medium height
                    },
                    .large()
                ]

                
                // Start in half-screen
                sheet.selectedDetentIdentifier = .medium
                
                // Show the top horizontal line ("grabber")
                sheet.prefersGrabberVisible = true
                
                // Nice extras (optional)
               
                sheet.prefersScrollingExpandsWhenScrolledToEdge = true
               
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
            sheet.largestUndimmedDetentIdentifier = .medium
            
            
            }
        
        navigationItem.title = "Comments"
        navigationController?.navigationBar.prefersLargeTitles = false
       
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setup()
        
       setupNavBar()
      
        configureDataSource()
        
        bindToViewModel()
//        Task { await vm.start() }
        vm.loadMockData()
    }
    func setup() {
        self.view.backgroundColor = .systemBackground
        self.postCommentTableView.contentInset = UIEdgeInsets(top: 50, left: 0, bottom: 35, right: 0)
        
        self.view.addSubview(postCommentTableView)
        NSLayoutConstraint.activate([
            postCommentTableView.topAnchor.constraint(equalTo: self.view.topAnchor),
            postCommentTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            postCommentTableView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            postCommentTableView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor)
        ])
        
    }
    
    private func toggleFooterSpinner(visible: Bool) {
        if visible {
            let spinner = UIActivityIndicatorView(style: .medium)
            spinner.startAnimating()
            spinner.frame = CGRect(x: 0, y: 0, width: postCommentTableView.bounds.width, height: 44)
            postCommentTableView.tableFooterView = spinner
        } else {
            postCommentTableView.tableFooterView = nil
        }
    }

    func bindToViewModel() {
        vm.$comments
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] comments in
                        self?.updateData(comments: comments)
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
   
    func updateData(comments: [PostComment]) {
        var snapshot = NSDiffableDataSourceSnapshot<CommentSection, PostComment>()
        snapshot.appendSections([.main])
        snapshot.appendItems(comments, toSection: .main)
        DispatchQueue.main.async {
            self.dataSource?.apply(snapshot, animatingDifferences: false)
        }
    }
  
    
    func configureDataSource() {
        dataSource = UITableViewDiffableDataSource<CommentSection, PostComment>(
            tableView: postCommentTableView
        ) { [weak self] tableView, indexPath, comment in
            let cell = tableView.dequeueReusableCell(
                withIdentifier: PostCommentTableViewCell.reuseID,
                for: indexPath
            ) as! PostCommentTableViewCell

//            cell.delegate = self
            cell.configure(with: comment)
            return cell
        }
        postCommentTableView.dataSource = dataSource
    }
    
    
    
    
}

// MARK: - Scrolling → infinite load trigger
extension PostCommentViewController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let threshold = scrollView.contentSize.height - scrollView.bounds.height * 1.8
        if offsetY > threshold {
           
            Task {await vm.loadMore() }
        }
    }
}

extension PostCommentViewController: PostCommentCellDelegate {
   
    func commentCellDidTapMore(_ cell: PostCommentTableViewCell) {
        // action sheet etc.
    }

   
}

#Preview {
    PostFeedViewController()
}
