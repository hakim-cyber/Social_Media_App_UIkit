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
    let commentContainerView:UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .systemBackground
    
        return v
    }()
    let commentTextField = CommentTextField()
    let avatarImageView = RoundedImageView(url: nil, isCircular: true)
    // Pull-to-refresh
   
    init(vm:CommentViewModel,) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
        
      
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func setupNavBar() {
        navigationItem.title = "Comments"
             
       
    }
    @objc private func closeTapped() {
            dismiss(animated: true)
        }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setup()
        
       setupNavBar()
      
        configureDataSource()
        
        bindToViewModel()
  Task { await vm.start() }
      
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let h = commentContainerView.bounds.height
        postCommentTableView.contentInset.bottom = h
        postCommentTableView.verticalScrollIndicatorInsets.bottom = h
    }
    func setup() {
        view.backgroundColor = .systemBackground

        view.addSubview(postCommentTableView)
        view.addSubview(commentContainerView)
        commentContainerView.addSubview(avatarImageView)
        commentContainerView.addSubview(commentTextField)

        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        commentTextField.translatesAutoresizingMaskIntoConstraints = false
        commentContainerView.translatesAutoresizingMaskIntoConstraints = false
        postCommentTableView.translatesAutoresizingMaskIntoConstraints = false

        // ✅ Make container prefer its content height
        commentContainerView.setContentHuggingPriority(.required, for: .vertical)
        commentContainerView.setContentCompressionResistancePriority(.required, for: .vertical)

        // ✅ Minimum height only (no max unless you want to clamp)
        let minH = commentContainerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 50)
        minH.isActive = true

        NSLayoutConstraint.activate([
            // Container pinned to keyboard
            commentContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            commentContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            commentContainerView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor),

            // Avatar (fixed size, aligned)
            avatarImageView.leadingAnchor.constraint(equalTo: commentContainerView.leadingAnchor, constant: 12),
            avatarImageView.bottomAnchor.constraint(equalTo: commentTextField.bottomAnchor,constant: -8),
            avatarImageView.heightAnchor.constraint(equalToConstant: 46),
            avatarImageView.widthAnchor.constraint(equalTo: avatarImageView.heightAnchor),

            // CommentTextField fills container vertically (THIS was missing)
            commentTextField.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor),
            commentTextField.trailingAnchor.constraint(equalTo: commentContainerView.trailingAnchor),
            commentTextField.topAnchor.constraint(equalTo: commentContainerView.topAnchor),
            commentTextField.bottomAnchor.constraint(equalTo: commentContainerView.bottomAnchor),

            // Table sits above container
            postCommentTableView.topAnchor.constraint(equalTo: view.topAnchor),
            postCommentTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            postCommentTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            postCommentTableView.bottomAnchor.constraint(equalTo: commentContainerView.topAnchor)
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

    func setProfileImage(summary:UserSummary){
        if let avatarURL = summary.avatarURL { avatarImageView.setImage(url: avatarURL) }
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
        
        vm.$currentUserSummary
            .removeDuplicates()
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
               
                self?.setProfileImage(summary:user)
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
