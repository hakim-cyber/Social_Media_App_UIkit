//
//  FlowDependencies.swift
//  Social_Media_App_UIkit
//
//  Created by Codex on 4/1/26.
//

import Foundation
import Supabase

struct AuthFlowDependencies {
    let onboardingService: any OnboardingServicing
    let authService: any AuthServicing
    let socialAuthService: any SocialAuthServicing
}

struct MainOnboardingDependencies {
    let profileService: any ProfileServicing
    let usernameValidator: any UsernameValidating
}

struct MainFeedDependencies {
    let sessionStore: SessionStoreProtocol
    let supabaseClient: SupabaseClient
    let feedService: any FeedServicing
    let commentService: any CommentServicing
    let userService: any UserServicing
    let postActionService: any PostActionServicing
    let translationService: any TranslationService
}

struct MainSearchDependencies {
    let sessionStore: SessionStoreProtocol
    let searchService: any SearchServicing
}

struct MainProfileDependencies {
    let sessionStore: SessionStoreProtocol
    let profileService: any ProfileServicing
    let followService: any FollowServicing
    let postQueryService: any PostQueryServicing
    let postActionService: any PostActionServicing
    let translationService: any TranslationService
    let usernameValidator: any UsernameValidating
    let authService: any AuthServicing
}

struct MainCreatePostDependencies {
    let postActionService: any PostActionServicing
}

struct MainFlowDependencies {
    let onboarding: MainOnboardingDependencies
    let feed: MainFeedDependencies
    let search: MainSearchDependencies
    let profile: MainProfileDependencies
    let createPost: MainCreatePostDependencies
}
