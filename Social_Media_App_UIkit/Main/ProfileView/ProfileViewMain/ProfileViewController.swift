//
//  ProfileViewController.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 12/20/25.
//

import UIKit
import Foundation
import Combine


class ProfileViewController: UIViewController,UIScrollViewDelegate,UICollectionViewDelegate {
    nonisolated enum Section: Hashable { case grid }
    
    private var cancellables = Set<AnyCancellable>()
    
    
    let vm:ProfileViewModel
    weak var coordinator: ProfileCoordinating?
    
    private let outerScroll = UIScrollView()
    private let contentView = UIView()

    
    // Views
   
    let profileHeaderView:ProfileHeaderView
    private let tabsView :ProfileTabsReusableView
    private lazy var postsCollectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: makeTwoColumnLayout())
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .clear
        cv.register(ProfilePostCell.self, forCellWithReuseIdentifier: ProfilePostCell.reuseID)
        return cv
    }()
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, UUID>?
    private var postById: [UUID: Post] = [:]
    
    private var collectionHeightConstraint: NSLayoutConstraint!
    
    private let refreshControl = UIRefreshControl()
    init(vm:ProfileViewModel) {
        
        self.vm = vm
        self.profileHeaderView = ProfileHeaderView(isCurrentUser: vm.isCurrentUser)
        self.tabsView = ProfileTabsReusableView(frame: .zero, isCurrentUser: vm.isCurrentUser)
        super.init(nibName: nil, bundle: nil)
        
        
    }
    
    private func makeTwoColumnLayout(spacing: CGFloat = 12) -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = spacing

        // itemSize will be set in viewDidLayoutSubviews (to respect safe area width)
        return layout
    }
    private func setupNavBar() {
      
        navigationItem.title = vm.profile?.username ?? ""
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setup()
        setupNavBar()
        configureDataSource()
        postsCollectionView.delegate = self
        bindToViewModel()
        setupRefreshControl()
//        Task{
//          await  vm.start()
//        }
    }
    private func setupRefreshControl() {
        outerScroll.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
    }
    @objc private func didPullToRefresh() {
        Task { [weak self] in
            guard let self else { return }

            // refresh (re-fetch)
            await self.vm.start()

            // stop spinner on main
            await MainActor.run {
                self.refreshControl.endRefreshing()
            }
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Task{
        await    self.vm.start()
        }
    }
        
    private func configureDataSource() {
           dataSource = UICollectionViewDiffableDataSource<Section, UUID>(
               collectionView: postsCollectionView
           ) { [weak self] collectionView, indexPath, id in
               guard let self else { return nil }

              let cell = collectionView.dequeueReusableCell(
                   withReuseIdentifier: ProfilePostCell.reuseID,
                   for: indexPath
               ) as! ProfilePostCell
               if  let post = self.postById[id]{
                   
                   cell.configure(post: post)
               }else{
                   cell.configure(post: .mockPost)
               }

               return cell
           }
       }
    private func apply(items: [Post], animating: Bool = true) {
        print("Applying \(items.count) ")
        postById = Dictionary(uniqueKeysWithValues: items.map { ($0.id, $0) })

        var snapshot = NSDiffableDataSourceSnapshot<Section, UUID>()
        snapshot.appendSections([.grid])
        snapshot.appendItems(items.map(\.id), toSection: .grid)

        dataSource?.apply(snapshot, animatingDifferences: animating)
        self.updateCollectionHeight()
    }
    private func updateCollectionHeight() {
        postsCollectionView.layoutIfNeeded()
        collectionHeightConstraint.constant = postsCollectionView.collectionViewLayout.collectionViewContentSize.height
        view.layoutIfNeeded()
    }
    func setup() {
        
        outerScroll.delegate = self
        view.backgroundColor = .systemBackground
        outerScroll.backgroundColor = .clear
        contentView.backgroundColor = .clear
        outerScroll.showsVerticalScrollIndicator = false
        
      
        outerScroll.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(outerScroll)
        outerScroll.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            outerScroll.topAnchor.constraint(equalTo: view.topAnchor),
            outerScroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            outerScroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            outerScroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            
            // contentView defines scroll content size (vertical)
               contentView.topAnchor.constraint(equalTo: outerScroll.contentLayoutGuide.topAnchor),
               contentView.bottomAnchor.constraint(equalTo: outerScroll.contentLayoutGuide.bottomAnchor),

               // ✅ THIS is the key fix: pin contentView horizontally to the *frameLayoutGuide*
               contentView.leadingAnchor.constraint(equalTo: outerScroll.leadingAnchor),
               contentView.trailingAnchor.constraint(equalTo: outerScroll.trailingAnchor),
            
            contentView.widthAnchor.constraint(equalTo: outerScroll.frameLayoutGuide.widthAnchor)
            ])
        setupHeaderView()
        setupTabPicker()
        
    }
    func setupHeaderView(){
        profileHeaderView.delegate = self
        profileHeaderView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(profileHeaderView)
        NSLayoutConstraint.activate([
            self.profileHeaderView.topAnchor.constraint(equalTo: self.contentView.safeAreaLayoutGuide.topAnchor),
            self.profileHeaderView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.profileHeaderView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
          
        ])
    }
    func setupTabPicker(){
        tabsView.tabPicker.onSelect = { [weak self] tab in
            guard let self else { return }
            self.vm.selectTab(tab)
        }
        tabsView.translatesAutoresizingMaskIntoConstraints = false
        postsCollectionView.translatesAutoresizingMaskIntoConstraints = false

        postsCollectionView.backgroundColor = .clear

        // inner starts disabled until tabs stick
        postsCollectionView.isScrollEnabled = false
        postsCollectionView.alwaysBounceVertical = true
        postsCollectionView.delegate = self

        outerScroll.delegate = self
       
     
      
       
      
        contentView.addSubview(tabsView)
        contentView.addSubview(postsCollectionView)
        
        
        collectionHeightConstraint = postsCollectionView.heightAnchor.constraint(equalToConstant: 1)

        NSLayoutConstraint.activate([
            tabsView.topAnchor.constraint(equalTo: profileHeaderView.bottomAnchor, constant: 35),
            tabsView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            tabsView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            tabsView.heightAnchor.constraint(equalToConstant: 48),

            postsCollectionView.topAnchor.constraint(equalTo: tabsView.bottomAnchor, constant: 12),
            postsCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            postsCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),

            collectionHeightConstraint,
            postsCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView === outerScroll else { return }

        let threshold: CGFloat = 300  // how close to bottom before loading
        let visibleBottom = scrollView.contentOffset.y + scrollView.bounds.height
        let contentHeight = scrollView.contentSize.height

        if visibleBottom >= contentHeight - threshold {
            vm.loadMoreIfNeeded()
            print("Load more")
            
        }
    }
    func bindToViewModel() {
        vm.$selectedTab
               .removeDuplicates()
               .receive(on: DispatchQueue.main)
               .sink { [weak self] _ in
                   guard let self else { return }
                   print("chang selected tab")
                   self.apply(items: self.vm.activePosts, animating: true)
               }
               .store(in: &cancellables)
        vm.$posts
               .receive(on: DispatchQueue.main)
               .sink { [weak self] _ in
                   guard let self else { return }
                   if self.vm.selectedTab == .posts {
                       self.apply(items: self.vm.posts, animating: true)
                   }
               }
               .store(in: &cancellables)
        vm.$likedPosts
               .receive(on: DispatchQueue.main)
               .sink { [weak self] _ in
                   guard let self else { return }
                   if self.vm.selectedTab == .liked {
                       self.apply(items: self.vm.likedPosts, animating: true)
                   }
               }
               .store(in: &cancellables)

           vm.$savedPosts
               .receive(on: DispatchQueue.main)
               .sink { [weak self] _ in
                   guard let self else { return }
                   if self.vm.selectedTab == .saved {
                       self.apply(items: self.vm.savedPosts, animating: true)
                   }
               }
               .store(in: &cancellables)
        vm.$profile
            .compactMap { $0 }
            .removeDuplicates()
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] profile in
                        self?.profileHeaderView.setProfileData(profile: profile)
                        self?.tabsView.tabPicker.setTitle(profile.post_count?.shortFormatted ?? "0", for: .posts)
                       
                        self?.navigationItem.title = profile.username
                    }
                    .store(in: &cancellables)
        
        
        vm.$isFollowing
                .removeDuplicates()
                .receive(on: DispatchQueue.main)
                .sink { [weak self] following in
                    self?.profileHeaderView.setFollowButtonState(isFollowing: following)
                }
                .store(in: &cancellables)
       
                vm.$errorMessage
                    .compactMap { $0 }
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] msg in
                        self?.showToast(msg)
                    }
                    .store(in: &cancellables)
        vm.$profileCount
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newCount in
                guard let self else { return }
               print("change counts")
                self.tabsView.tabPicker.setTitle(newCount.liked.shortFormatted, for: .liked)
                self.tabsView.tabPicker.setTitle(newCount.saved.shortFormatted, for: .saved)
            }
            .store(in: &cancellables)
    }
    
   
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
       updateItemSizeIfNeeded()
        updateCollectionHeight()
    }
  
    
    private func updateItemSizeIfNeeded() {
            guard let layout = postsCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }

            let spacing = layout.minimumInteritemSpacing
            let totalSpacing = spacing * 1 // 2 columns -> 1 gap
            let width = postsCollectionView.bounds.width - totalSpacing
            let item = floor(width / 2)

            if layout.itemSize.width != item {
                layout.itemSize = CGSize(width: item, height: item)
                layout.invalidateLayout()
            }
        }
    
}

#Preview {
    ProfileViewController(vm: .init(target: .user(id: UUID())))
}

extension ProfileViewController:ProfileHeaderViewDelegate{
    func didTapFollowerCount() {
        self.coordinator?.didTapFollowers()
    }
    
    func didTapFollowingCount() {
        self.coordinator?.didTapFollowing()
    }
    
    func followButtonTapped() {
        self.vm.toggleFollow()
    }
    
    func messageButtonTapped() {
        self.coordinator?.didTapMessage()
        print("messageButtonTapped")
    }
    
    func editProfileButtonTapped() {
        self.coordinator?.didTapEditProfile()
        print("editProfileButtonTapped")
    }
    
    func shareProfileButtonTapped() {
        self.coordinator?.didTapShareProfile()
        print("shareProfileButtonTapped")
    }
    
    
}
extension ProfileViewController{
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        if let selectedPost = vm.activePosts[safe: indexPath.item]{
            self.coordinator?.didSelectPostCell(post: selectedPost)
        }
       
    }
}
