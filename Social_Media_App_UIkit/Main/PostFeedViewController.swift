//
//  File.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 10/19/25.
//
import UIKit
import Foundation

nonisolated enum PostFeedSection: Hashable, Sendable {
    case main
}

class PostFeedViewController: UIViewController {
    
//    var viewModel:
//    private var cancellables = Set<AnyCancellable>()
    
    var dataSource: UITableViewDiffableDataSource<PostFeedSection, Post>?
    
    init() {
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
    
    func bindToViewModel() {
        Task{
            do{
                let posts = try await FeedService().loadGlobalFeed()
                print(posts)
            }catch{
                print(error)
            }
        }
    }
   
    func updateData(posts: [Post]) {
        var snapshot = NSDiffableDataSourceSnapshot<PostFeedSection, Post>()
        snapshot.appendSections([.main])
        snapshot.appendItems(posts, toSection: .main)
        DispatchQueue.main.async {
            self.dataSource?.apply(snapshot, animatingDifferences: true)
        }
    }
  
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
      
        return tv
    }()
    
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

private extension PostFeedViewController {
    func setup() {
        self.view.backgroundColor = .systemBackground
        self.postFeedTableView.contentInset = UIEdgeInsets(top: 50, left: 0, bottom: 35, right: 0)
        
        self.view.addSubview(postFeedTableView)
        NSLayoutConstraint.activate([
            postFeedTableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            postFeedTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            postFeedTableView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            postFeedTableView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
}

#Preview {
    PostFeedViewController()
}
