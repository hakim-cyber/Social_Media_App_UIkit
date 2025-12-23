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
    
    private let outerScroll = UIScrollView()
    private let contentView = UIView()

    
    // Views
   
    let profileHeaderView:ProfileHeaderView
    private let tabsView = ProfileTabsReusableView()
    private lazy var postsCollectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: makeTwoColumnLayout())
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .clear
        cv.register(ProfilePostCell.self, forCellWithReuseIdentifier: ProfilePostCell.reuseID)
        return cv
    }()
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, UUID>?
    private var postById: [UUID: Post] = [:]
    
    init(vm:ProfileViewModel) {
        
        self.vm = vm
        self.profileHeaderView = ProfileHeaderView(isCurrentUser: vm.isCurrentUser)
        super.init(nibName: nil, bundle: nil)
        
        
    }
    
    private func makeTwoColumnLayout(spacing: CGFloat = 2) -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = spacing

        // itemSize will be set in viewDidLayoutSubviews (to respect safe area width)
        return layout
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setup()
        configureDataSource()
        postsCollectionView.delegate = self
        bindToViewModel()
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
        postById = Dictionary(uniqueKeysWithValues: items.map { ($0.id, $0) })

        var snapshot = NSDiffableDataSourceSnapshot<Section, UUID>()
        snapshot.appendSections([.grid])
        snapshot.appendItems(items.map(\.id), toSection: .grid)

        dataSource?.apply(snapshot, animatingDifferences: animating)
    }
    func setup() {
        
       
        view.backgroundColor = .quaternarySystemFill
      
        outerScroll.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(outerScroll)
        outerScroll.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            outerScroll.topAnchor.constraint(equalTo: view.topAnchor),
            outerScroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            outerScroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            outerScroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            
            contentView.topAnchor.constraint(equalTo: outerScroll.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: outerScroll.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: outerScroll.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: outerScroll.contentLayoutGuide.bottomAnchor),
            
            contentView.widthAnchor.constraint(equalTo: outerScroll.frameLayoutGuide.widthAnchor),
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
            switch tab {
            case .grid:  self.vm.selectTab(.posts)
            case .like:  self.vm.selectTab(.liked)
            case .saved: self.vm.selectTab(.saved)
            }
        }
        tabsView.translatesAutoresizingMaskIntoConstraints = false
        postsCollectionView.translatesAutoresizingMaskIntoConstraints = false

        postsCollectionView.backgroundColor = .clear

        // inner starts disabled until tabs stick
        postsCollectionView.isScrollEnabled = false
        postsCollectionView.alwaysBounceVertical = true

        outerScroll.delegate = self
        contentView.addSubview(tabsView)
        contentView.addSubview(postsCollectionView)
        
        
        NSLayoutConstraint.activate([
            tabsView.topAnchor.constraint(equalTo: profileHeaderView.bottomAnchor,constant: 20),
            tabsView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: 12),
            tabsView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,constant: -12),
            tabsView.heightAnchor.constraint(equalToConstant: 48),

            postsCollectionView.topAnchor.constraint(equalTo: tabsView.bottomAnchor),
            postsCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            postsCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            postsCollectionView.heightAnchor.constraint(equalTo: outerScroll.frameLayoutGuide.heightAnchor),
            postsCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            
            ])
        
        // ALSO: make inner collection view drive outer when it reaches top again
        postsCollectionView.panGestureRecognizer.addTarget(self, action: #selector(handleInnerPan))
      
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView === outerScroll else { return }

        let stickOffset = stickyOffset()

        if outerScroll.contentOffset.y >= stickOffset {
            outerScroll.contentOffset.y = stickOffset
            if !postsCollectionView.isScrollEnabled {
                postsCollectionView.isScrollEnabled = true
            }
        } else {
            // header still visible => inner should not scroll
            if postsCollectionView.isScrollEnabled {
                postsCollectionView.isScrollEnabled = false
                postsCollectionView.contentOffset.y = 0
            }
        }
    }
    private func stickyOffset() -> CGFloat {
        view.layoutIfNeeded()
        contentView.layoutIfNeeded()
        let tabsY = tabsView.frame.minY
        let safeTop = view.safeAreaInsets.top
        return max(0, tabsY - safeTop)
    }

    @objc private func handleInnerPan() {
        let velocity = postsCollectionView.panGestureRecognizer.velocity(in: postsCollectionView)
        let isPanningDown = velocity.y > 0

        if isPanningDown, postsCollectionView.contentOffset.y <= 0 {
            postsCollectionView.isScrollEnabled = false
        }
    }
    func bindToViewModel() {
        vm.$selectedTab
               .removeDuplicates()
               .receive(on: DispatchQueue.main)
               .sink { [weak self] _ in
                   guard let self else { return }
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

    }
    
   
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
       updateItemSizeIfNeeded()
       
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
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {

        let count = vm.activePosts.count
        let threshold = max(0, count - 9)

        if indexPath.item == threshold {
            vm.loadMoreIfNeeded()
        }
    }
}

#Preview {
    ProfileViewController(vm: .init(target: .user(id: UUID())))
}

extension ProfileViewController:ProfileHeaderViewDelegate{
    func followButtonTapped() {
        self.vm.toggleFollow()
    }
    
    func messageButtonTapped() {
        print("messageButtonTapped")
    }
    
    func editProfileButtonTapped() {
        print("editProfileButtonTapped")
    }
    
    func shareProfileButtonTapped() {
        print("shareProfileButtonTapped")
    }
    
    
}
