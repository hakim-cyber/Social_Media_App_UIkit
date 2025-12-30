//
//  FollowersListViewController.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 12/29/25.
//

import Foundation

protocol FollowerListCellDelegate:AnyObject{
    func didTapProfile(cell:FollowerListCell)
    func didTapFollow(cell:FollowerListCell)
    func didTapMore(cell:FollowerListCell)
}


//
//  ProfilePostFeedViewController.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 12/27/25.
//

import UIKit
import Foundation
import Combine

class FollowersListViewController: UIViewController {
    
    nonisolated enum Section: Hashable, Sendable {
        case main
    }

    private var cancellables = Set<AnyCancellable>()
    
    var dataSource: UITableViewDiffableDataSource<Section, UserFollowItem>?
    let vm:FollowersListViewModel
  
    weak var coordinator: FollowerListCoordinating?
   
    private lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.showsVerticalScrollIndicator = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = .clear
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = self.view.bounds.height / 8.5
        tv.separatorStyle = .none
        tv.register(FollowerListCell.self, forCellReuseIdentifier: FollowerListCell.reuseID)
        tv.allowsSelection = true
        tv.delegate = self
        
        return tv
    }()
    private  let tabView :TabPickerView<FollowerListTarget>
    init(vm:FollowersListViewModel) {
        self.vm = vm
        
        self.tabView = .init(items:
                            [
                                .init(id: .followers, selectedIcon: nil, unselectedIcon: nil,title: "Followers"),
                                .init(id: .following, selectedIcon: nil, unselectedIcon: nil,title: "Following")
                            ], selectedID: vm.target)
        super.init(nibName: nil, bundle: nil)
    
      
    }
   
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func setupNavBar() {
        self.navigationItem.title = vm.selectedUser.username
        
    }
   

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setup()
        
       setupNavBar()
        configureDataSource()
       
        bindToViewModel()
//        Task { await vm.start() }
     
    }
   
    func setup() {
        setupTabView()
    }
    func setupTabView(){
        self.view.addSubview(tabView)
        tabView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tabView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tabView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tabView.heightAnchor.constraint(equalToConstant: 48)
            ]
        )
    }
   
    
    func returnToTopRow(){
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.scrollToRow(at: indexPath, at: .top, animated: true)
    }
    
    
    private func toggleFooterSpinner(visible: Bool) {
        if visible {
            let spinner = UIActivityIndicatorView(style: .medium)
            spinner.startAnimating()
            spinner.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 44)
            tableView.tableFooterView = spinner
        } else {
            tableView.tableFooterView = nil
        }
    }

    func bindToViewModel() {
        
        vm.$target
               .removeDuplicates()
               .receive(on: DispatchQueue.main)
               .sink { [weak self] _ in
                   guard let self else { return }
                   print("chang selected tab")
                   self.apply(follows: self.vm.activeFollow)
                  
               }
               .store(in: &cancellables)
        vm.$followers
               .receive(on: DispatchQueue.main)
               .sink { [weak self] new in
                   guard let self else { return }
                   if self.vm.target == .followers {
                       self.apply(follows:  new)
                   }
               }
               .store(in: &cancellables)
        vm.$followings
               .receive(on: DispatchQueue.main)
               .sink { [weak self] new in
                   guard let self else { return }
                   if self.vm.target == .following {
                       self.apply(follows:  new)
                   }
               }
               .store(in: &cancellables)
        
       
                vm.$errorMessage
                    .compactMap { $0 }
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] msg in
                        self?.showToast(msg)
                    }
                    .store(in: &cancellables)
        vm.$followerCount
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newCount in
                guard let self else { return }
              
                self.tabView.setTitle("Followers \(newCount.shortFormatted)", for: .followers)
                
            
            }
            .store(in: &cancellables)
        vm.$followingCount
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newCount in
                guard let self else { return }
              
                self.tabView.setTitle("Following \(newCount.shortFormatted)", for: .following)
            
            }
            .store(in: &cancellables)
    }
   
    func apply(follows: [UserFollowItem]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, UserFollowItem>()
        snapshot.appendSections([.main])
        snapshot.appendItems(follows, toSection: .main)
        DispatchQueue.main.async {
            self.dataSource?.apply(snapshot, animatingDifferences: true)
        
        }
    }
  
    
    func configureDataSource() {
        dataSource = UITableViewDiffableDataSource<Section, UserFollowItem>(
            tableView: tableView
        ) { [weak self] tableView, indexPath, follow in
            let cell = tableView.dequeueReusableCell(
                withIdentifier: FollowerListCell.reuseID,
                for: indexPath
            ) as! FollowerListCell

            cell.delegate = self
            cell.configure(with: follow, target: self?.vm.target ?? .following)
            return cell
        }
        tableView.dataSource = dataSource
    }
    
    
    
    
}

// MARK: - Scrolling → infinite load trigger
extension FollowersListViewController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let threshold = scrollView.contentSize.height - scrollView.bounds.height * 1.8
        if offsetY > threshold {
//
//            vm.loadMoreIfNeeded()
        }
    }
}
extension FollowersListViewController:FollowerListCellDelegate{
    func didTapProfile(cell: FollowerListCell) {
        guard let user = cell.user else {return}
       
    }
    
    func didTapFollow(cell: FollowerListCell) {
        guard let user = cell.user else {return}
        
    }
    
    func didTapMore(cell: FollowerListCell) {
        guard let user = cell.user else {return}
    }
    
    
}
#Preview {
    PostFeedViewController(vm:FeedViewModel(service: .init(), realtime: .init()))
}
