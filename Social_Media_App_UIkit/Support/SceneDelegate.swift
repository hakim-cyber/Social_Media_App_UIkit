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
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }

               // Setup window
               let window = UIWindow(windowScene: windowScene)
        window.tintColor = .electricPurple
               self.window = window
               window.makeKeyAndVisible()
        
        let appCoordinator = AppCoordinator(window: window)
               self.appCoordinator = appCoordinator

               // Start coordinator
               appCoordinator.start(animated: false)
    }
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        for context in URLContexts {
            let url = context.url
            
            // 1️⃣ Handle Google Sign-In
            if GIDSignIn.sharedInstance.handle(url) {
                return
            }
            
            // 2️⃣ Handle Supabase Email Confirmation / Auth Callback
            if url.scheme == "myapp" { // your custom URL scheme
                Task {
                            do {
                                if let deepLink = DeepLinkRouter.parse(url: url) {
                                    await handleDeepLink(deepLink,url: url)
                                }
                            } catch {
                                print("Deep link handling failed:", error)
                            }
                        }
            }
            
            // 3️⃣ Handle other URLs if needed
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
    private func handleDeepLink(_ link: AppDeepLink,url:URL) async {
        switch link {
        case .resetPassword:
            try? await handleForgotPasswordLink(url: url)

        case .auth:
            try? await handleEmailConfirmationLink(url:url)

        case .profile(let userId):
            self.appCoordinator?.showProfile(userid: userId)
            print("Show Profile")
        }
    }
    private func handleEmailConfirmationLink(url: URL) async throws {
        // Restore session and auto-login
        let _ = try await AuthService.shared.restoreSession(from: url)
      //  authCoordinator.handleLoginSuccess(user: user)
    }

    private func handleForgotPasswordLink(url: URL) async throws {
        // Restore session (optional)
        let user = try await AuthService.shared.restoreSession(from: url)
        
        self.appCoordinator?.showChangePasswordViewController()
     
    }
}
