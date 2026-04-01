//
//  AppContainer.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 4/1/26.
//


import Foundation
import Supabase

final class AppContainer {
    let configuration: AppConfiguration
    let supabaseClient: SupabaseClient

    let sessionStore: SessionStoreProtocol
    let sessionService: UserSessionService
    let onboardingService: OnboardingService
    let storageService: SupabaseStorageService
    let profileAvatarService: ProfileAvatarService
    let profileService: ProfileService
    let authService: AuthServicing
    let socialAuthService: SocialAuthServicing

    init(configuration: AppConfiguration) {
        self.configuration = configuration

        let client = SupabaseClient(
            supabaseURL: configuration.supabaseURL,
            supabaseKey: configuration.supabaseAnonKey
        )
        self.supabaseClient = client

        let sessionService = UserSessionService(client: client)
        self.sessionService = sessionService
        self.sessionStore = sessionService

        self.onboardingService = OnboardingService(defaults: .standard)

        let storageService = SupabaseStorageService(client: client)
        self.storageService = storageService

        let avatarService = ProfileAvatarService(
            client: client,
            storage: storageService
        )
        self.profileAvatarService = avatarService

        self.profileService = ProfileService(
            client: client,
            avatarService: avatarService
        )

        let authService = AuthService(
            client: client,
            sessionStore: sessionService,
            passwordResetRedirectURL: URL(string: "myapp://auth-callback/account/update-password")!
        )
        self.authService = authService
        AuthService.configureShared(authService)

        self.socialAuthService = SocialAuthService(
            authService: authService,
            googleSignInFlow: GoogleSignInHelper(),
            appleSignInFlow: AppleSignInHelper()
        )
    }
}
