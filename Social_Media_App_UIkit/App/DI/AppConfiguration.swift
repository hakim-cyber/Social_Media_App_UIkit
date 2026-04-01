//
//  AppConfiguration.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 4/1/26.
//


import Foundation

struct AppConfiguration {
    let supabaseURL: URL
    let supabaseAnonKey: String
    let deepLAPIKey: String

    static func fromBundle(_ bundle: Bundle = .main) -> AppConfiguration {
        guard
            let supabaseURLString = bundle.object(forInfoDictionaryKey: "SUPABASE_URL") as? String,
            let supabaseURL = URL(string: supabaseURLString),
            let supabaseAnonKey = bundle.object(forInfoDictionaryKey: "SUPABASE_ANON_KEY") as? String,
            let deepLAPIKey = bundle.object(forInfoDictionaryKey: "DEEPL_API_KEY") as? String
        else {
            fatalError("Missing app configuration values")
        }

        return AppConfiguration(
            supabaseURL: supabaseURL,
            supabaseAnonKey: supabaseAnonKey,
            deepLAPIKey: deepLAPIKey
        )
    }
}
