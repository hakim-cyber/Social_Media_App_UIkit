//
//  MainCoordinator.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 10/1/25.
//

import UIKit

final class MainCoordinator: NSObject,Coordinator, ParentCoordinator {
    
    // MARK: - ParentCoordinator
    var childCoordinators: [Coordinator] = []

    // MARK: - Shared services
    let onboardingService: OnboardingService
    let profileService: ProfileService

    // MARK: - Root
    /// This is the REAL root of the main app (AppCoordinator sets this as window.rootViewController)
    let tabBarController = UITabBarController()

    // Nav controllers per tab
    private let feedNav = UINavigationController()
    private let profileNav = UINavigationController()
    private let searchNav = UINavigationController()
    // later: private let notifNav = UINavigationController()
    // later: private let profileNav = UINavigationController()

    // Child coordinators
    private var feedCoordinator: FeedCoordinator?
    private var profileCoordinator: ProfileCoordinator?
    private var searchCoordinator: SearchProfileCoordinator?
    private var onboardingCoordinator: OnboardingSetupCoordinator?
    private var createPostCoordinator: CreatePostCoordinator?
    private var onboardingNav: UINavigationController?
    let feedTabIndex: Int = 0
    let searchTabIndex: Int = 1
    let profileTabIndex: Int = 2

    // MARK: - Init

    init(onboardingService: OnboardingService) {
        self.onboardingService = onboardingService
        self.profileService = ProfileService()
    }

    // Main entry point
    func start(animated: Bool) {
        Task {
            await checkAndShowSetupIfNeeded()
        }
    }

    // MARK: - Profile / onboarding logic

    private func checkAndShowSetupIfNeeded() async {
        do {
            let userHasProfile = try await profileService.checkIfUserHasProfile()

            await MainActor.run {
                if userHasProfile {
                    // User already has profile → show main tabs
                    self.showMainView(animated: false)
                } else {
                    // No profile yet → show onboarding flow on top
                    self.showOnboardingSetup()
                }
            }
        } catch {
            print("Error checking profile: \(error)")
            await MainActor.run {
                // Fallback: treat as no profile, force onboarding
                self.showOnboardingSetup()
            }
        }
    }

    // MARK: - Tabs setup

    private func setupTabs() {
        // FEED TAB
        let feedCoordinator = FeedCoordinator(navigationController: feedNav)
        feedCoordinator.parentCoordinator = self
        addChild(feedCoordinator)
        feedCoordinator.start(animated: false)
        self.feedCoordinator = feedCoordinator

        feedNav.tabBarItem = UITabBarItem(
            title: "Feed",
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )

       
        
        
        

        let searchCoordinator = SearchProfileCoordinator(navigationController: searchNav)
        searchCoordinator.parentCoordinator = self
        addChild(searchCoordinator)
        searchCoordinator.start(animated: false)
        self.searchCoordinator = searchCoordinator

        searchNav.tabBarItem = UITabBarItem(
            title: "Search",
            image: UIImage(systemName: "magnifyingglass"),
            selectedImage: UIImage(systemName: "magnifyingglass")
        )
        
        let profileCoordinator = ProfileCoordinator(navigationController: profileNav, target: .me)
        profileCoordinator.parentCoordinator = self
        addChild(profileCoordinator)
        profileCoordinator.start(animated: false)
        self.profileCoordinator = profileCoordinator

        profileNav.tabBarItem = UITabBarItem(
            title: "Profile",
            image: UIImage(systemName: "person"),
            selectedImage: UIImage(systemName: "person.fill")
        )
        
        
        // CREATE (special separated tab)
           let createNav = UINavigationController()
        
           let createItem = UITabBarItem(tabBarSystemItem: .search, tag: 99)
           createItem.image = UIImage(systemName: "plus")
           createItem.selectedImage = UIImage(systemName: "plus")
           createItem.title = nil
           createNav.tabBarItem = createItem
     
        // Add more tabs later: searchNav, notifNav, profileNav...
        tabBarController.viewControllers = [
            feedNav,searchNav,profileNav,  createNav,
        ]
        tabBarController.delegate = self
        if #available(iOS 26.0, *) {
            tabBarController.tabBarMinimizeBehavior = .onScrollDown
        } else {
            // Fallback on earlier versions
        }
    }

    func showMainView(animated: Bool = true) {
        setupTabs()
      
    }

    func switchToMyProfile() {
        tabBarController.selectedIndex = profileTabIndex
        (profileNav).popToRootViewController(animated: false)
    }
    func showProfile(for userId:UUID){
        self.feedCoordinator?.showProfile(id: userId)
    }
    // MARK: - Onboarding flow

    private func showOnboardingSetup() {
        // Present onboarding modally over the tabBarController
        // (tabBarController is already root of the window)

        let nav = UINavigationController()
        nav.modalPresentationStyle = .fullScreen
        onboardingNav = nav

        let onboarding = OnboardingSetupCoordinator(
            navigationController: nav,
            profileService: profileService
        )
        onboarding.parentCoordinator = self
        addChild(onboarding)
        onboardingCoordinator = onboarding

        onboarding.start(animated: false)

        // Present from the tab bar (which is root)
        tabBarController.present(nav, animated: true)
    }

    // MARK: - ParentCoordinator

    func childDidFinish(_ child: Coordinator?) {
        childCoordinators.removeAll(where: {$0 === child})
        
        // When onboarding finishes → dismiss its nav and show tabs
        if child === onboardingCoordinator {
            onboardingCoordinator = nil
            
            onboardingNav?.dismiss(animated: true)
            onboardingNav = nil
            
            showMainView()
        }
        
        if child === feedCoordinator {
            feedCoordinator = nil
        }
        if child === createPostCoordinator {
            createPostCoordinator = nil
        }
    }
    private func presentCreateFlow() {
        guard let presenter = tabBarController.presentedViewController ?? tabBarController.selectedViewController else {
            return
        }

        let coord = CreatePostCoordinator(presenter: presenter)
        coord.parentCoordinator = self
        addChild(coord)                 // important: retain
        self.createPostCoordinator = coord

        coord.start(animated: true)
    }
}

extension MainCoordinator: UITabBarControllerDelegate {

    func tabBarController(
        _ tabBarController: UITabBarController,
        shouldSelect viewController: UIViewController
    ) -> Bool {

        if viewController.tabBarItem.tag == 99 {
            presentCreateFlow()
            return false
        }

        return true
    }
}
