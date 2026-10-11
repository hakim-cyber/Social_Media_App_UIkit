//
//  SceneDelegate.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 9/20/25.
//

import UIKit
import GoogleSignIn

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    var appCoordinator: AppCoordinator?
    private var container: AppContainer?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = scene as? UIWindowScene else { return }
        
        let window = UIWindow(windowScene: windowScene)
        window.tintColor = .electricPurple
        self.window = window
        window.makeKeyAndVisible()
        
        let configuration = AppConfiguration.fromBundle()
        let container = AppContainer(configuration: configuration)
        self.container = container
        
       let appLauncher = AppLauncher(container: container)
        appLauncher.configure() // for ui tests mainly
        
        let appCoordinator = AppCoordinator(window: window, container: container)
        
        self.appCoordinator = appCoordinator
        appCoordinator.start(animated: false)
        for context in connectionOptions.urlContexts {
            handleIncomingURL(context.url)
        }
    }
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        for context in URLContexts {
            handleIncomingURL(context.url)
        }
    }

    private func handleIncomingURL(_ url: URL) {
        if GIDSignIn.sharedInstance.handle(url) { return }
        guard let link = DeepLinkRouter.parse(url: url) else { return }
        Task { @MainActor in
            do {
                try await handleDeepLink(link, url: url)
            } catch {
                guard var presenter = window?.rootViewController else { return }
                while let presented = presenter.presentedViewController {
                    presenter = presented
                }
                AppAlertPresenter.showAlert(
                    title: "Couldn't open this link",
                    message: "The link may have expired or your connection may be unavailable. Please try again or request a new link.",
                    presenter: presenter
                )
            }
        }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
}


extension SceneDelegate{
    @MainActor
    private func handleDeepLink(_ link: AppDeepLink,url:URL) async throws {
        switch link {
        case .resetPassword:
            try await handleForgotPasswordLink(url: url)
        case .auth:
            try await handleEmailConfirmationLink(url:url)
        case .profile(let userId):
            self.appCoordinator?.showProfile(userid: userId)
            print("Show Profile")
        }
    }
    private func handleEmailConfirmationLink(url: URL) async throws {
        guard let authService = container?.authService else { return }
        let _ = try await authService.restoreSession(from: url)
    }
    
    private func handleForgotPasswordLink(url: URL) async throws {
        guard let authService = container?.authService else { return }
        let _ = try await authService.restoreSession(from: url)
        self.appCoordinator?.handleResetPasswordDeepLink()
    }
}
