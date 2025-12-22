//
//  ProfileViewController.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 12/20/25.
//

import UIKit
import Foundation
import Combine


class ProfileViewController: UIViewController,UIScrollViewDelegate {
    
    private var cancellables = Set<AnyCancellable>()
    
    
    let vm:ProfileViewModel
    
    private let outerScroll = UIScrollView()
    private let contentView = UIView()

    
    // Views
   
    let profileHeaderView:ProfileHeaderView
    private let tabsView = ProfileTabsReusableView()
    private let postsCollectionView: UICollectionView
    
    init(vm:ProfileViewModel) {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 2
        let w = UIScreen.main.bounds.width
        let itemW = (w - 4) / 3
        layout.itemSize = CGSize(width: itemW, height: itemW)
        postsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        
        self.vm = vm
        self.profileHeaderView = ProfileHeaderView(isCurrentUser: vm.isCurrentUser)
        super.init(nibName: nil, bundle: nil)
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setup()
        bindToViewModel()
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
            postsCollectionView.heightAnchor.constraint(equalTo: view.heightAnchor), // important
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
        // tabs top position in scroll content coordinates
        let tabsY = tabsView.frame.minY
        let safeTop = view.safeAreaInsets.top
        return max(0, tabsY - safeTop )
    }

    @objc private func handleInnerPan() {
        // If inner is at top and user scrolls downward, give control back to outer scroll
        if postsCollectionView.contentOffset.y <= 0 {
            postsCollectionView.isScrollEnabled = false
        }
    }
    func bindToViewModel() {
       
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
