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

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        window.tintColor = UIColor.electricPurple // your custom color
        window.rootViewController = UINavigationController(rootViewController: LoginViewController())
        window.makeKeyAndVisible()
        
        self.window = window
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
                        if url.path == "/account/update-password" {
                            // Forgot password / Reset flow
                            try await handleForgotPasswordLink(url: url)
                        } else {
                            // Email confirmation / generic deep link
                            try await handleEmailConfirmationLink(url: url)
                        }
                    } catch {
                        print("Failed to handle Supabase URL: \(error)")
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
    private func handleEmailConfirmationLink(url: URL) async throws {
        // Restore session and auto-login
        let user = try await AuthService.shared.restoreSession(from: url)
      //  authCoordinator.handleLoginSuccess(user: user)
    }

    private func handleForgotPasswordLink(url: URL) async throws {
        // Restore session (optional)
        let user = try await AuthService.shared.restoreSession(from: url)
        
        // Show Reset Password screen with coordinator
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                let window = windowScene.windows.first,
                let rootVC = window.rootViewController else { return }
          
          let resetVC = ForgotPasswordChangeVIew()
        resetVC.modalPresentationStyle = .automatic
          rootVC.present(resetVC, animated: true)
    }
}
