//
//  test.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 12/22/25.
//

import UIKit
final class ProfileNestedScrollVC: UIViewController, UIScrollViewDelegate {

    private let outerScroll = UIScrollView()
    private let contentView = UIView()

    private let headerView = ProfileHeaderView() // your existing header view
    private let tabsView = ProfileTabsReusableView() // or just tabPicker container
    private let postsCollectionView: UICollectionView

    private var isOuterLocked = false

    init() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 2
        let w = UIScreen.main.bounds.width
        let itemW = (w - 4) / 3
        layout.itemSize = CGSize(width: itemW, height: itemW)

        postsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        outerScroll.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        headerView.translatesAutoresizingMaskIntoConstraints = false
        tabsView.translatesAutoresizingMaskIntoConstraints = false
        postsCollectionView.translatesAutoresizingMaskIntoConstraints = false

        outerScroll.delegate = self

        // inner starts disabled until tabs stick
        postsCollectionView.isScrollEnabled = false
        postsCollectionView.alwaysBounceVertical = true

        view.addSubview(outerScroll)
        outerScroll.addSubview(contentView)
        contentView.addSubview(headerView)
        contentView.addSubview(tabsView)
        contentView.addSubview(postsCollectionView)

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

            headerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            tabsView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            tabsView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            tabsView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
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
        return max(0, tabsY - safeTop + 50)
    }

    @objc private func handleInnerPan() {
        // If inner is at top and user scrolls downward, give control back to outer scroll
        if postsCollectionView.contentOffset.y <= 0 {
            postsCollectionView.isScrollEnabled = false
        }
    }
}
