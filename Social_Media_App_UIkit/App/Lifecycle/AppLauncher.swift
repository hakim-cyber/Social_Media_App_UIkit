//
//  AppLauncher.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 4/29/26.
//

import Foundation

final class AppLauncher {

    private let launchArguments: LaunchArguments
    private let container: AppContainer

    init(container: AppContainer,
         launchArguments: LaunchArguments = LaunchArguments()) {
        self.container = container
        self.launchArguments = launchArguments
    }

    func configure(){
        handleOnboarding()
       
    }

    private func handleOnboarding(){
        if launchArguments.contains(.resetOnboarding) {
            container.onboardingService.resetHasSeenWelcome()
        }

        if launchArguments.contains(.skipWelcome) {
            container.onboardingService.setHasSeenWelcome()
        }
        Task{
            if launchArguments.contains(.forceLoggedOut) {
                container.sessionStore.clearSession()
            }
        }
    }
}
