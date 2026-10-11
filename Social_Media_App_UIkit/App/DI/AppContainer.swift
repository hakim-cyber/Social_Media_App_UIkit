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
   
    let onboardingService: any OnboardingServicing
    let storageService: any StorageUploading
    let profileAvatarService: any ProfileAvatarServicing
    let profileService: any ProfileServicing
    let authService: any AuthServicing
    let socialAuthService: any SocialAuthServicing

    let translationService: any TranslationService
    let usernameValidator: any UsernameValidating
    let userService: any UserServicing
    let postQueryService: any PostQueryServicing
    let postActionService: any PostActionServicing
    let commentService: any CommentServicing
    let followService: any FollowServicing
    let searchService: any SearchServicing
    let feedService: any FeedServicing

    init(configuration: AppConfiguration) {
        self.configuration = configuration

        let client = SupabaseClient(
            supabaseURL: configuration.supabaseURL,
            supabaseKey: configuration.supabaseAnonKey
        )
        self.supabaseClient = client

        let sessionService = UserSessionService(client: client)
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

        self.socialAuthService = SocialAuthService(
            authService: authService,
            googleSignInFlow: GoogleSignInHelper(),
            appleSignInFlow: AppleSignInHelper()
        )

        self.translationService = DeepLTranslationService(apiKey: configuration.deepLAPIKey)
        
        let usernameApi = SupabaseUsernameAPI(client: client)
        self.usernameValidator = UsernameValidator(api: usernameApi)
        
        self.userService = UserService(client: client)
        self.postQueryService = PostQueryService(client: client)
        self.postActionService = PostActionService(
            client: client,
            storageService: storageService
        )
        self.commentService = CommentService(client: client)
        self.followService = FollowService(client: client)
        self.searchService = SearchService(client: client)
        self.feedService = FeedService(client: client)
    }
}

extension AppContainer {
    var authFlowDependencies: AuthFlowDependencies {
        AuthFlowDependencies(
            onboardingService: onboardingService,
            authService: authService,
            socialAuthService: socialAuthService
        )
    }

    var mainFlowDependencies: MainFlowDependencies {
        MainFlowDependencies(
            onboarding: MainOnboardingDependencies(
                profileService: profileService,
                usernameValidator: usernameValidator
            ),
            feed: MainFeedDependencies(
                sessionStore: sessionStore,
                supabaseClient: supabaseClient,
                feedService: feedService,
                commentService: commentService,
                userService: userService,
                postActionService: postActionService,
                translationService: translationService
            ),
            search: MainSearchDependencies(
                sessionStore: sessionStore,
                searchService: searchService
            ),
            profile: MainProfileDependencies(
                sessionStore: sessionStore,
                profileService: profileService,
                followService: followService,
                postQueryService: postQueryService,
                postActionService: postActionService,
                translationService: translationService,
                usernameValidator: usernameValidator,
                authService: authService
            ),
            createPost: MainCreatePostDependencies(
                postActionService: postActionService
            )
        )
    }
}
