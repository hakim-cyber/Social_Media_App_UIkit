//
//  SupabaseUsernameAPI.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 4/25/26.
//
import Foundation
import Supabase

protocol UsernameAPI {
    func isUsernameAvailable(_ username: String) async throws -> Bool
}
struct SupabaseUsernameAPI: UsernameAPI {
    let client: SupabaseClient
    
    func isUsernameAvailable(_ username: String) async throws -> Bool {
        let response = try await client
            .from("users")
            .select("id", count: .exact)
            .ilike("username", pattern: username)
            .execute()
        
        return (response.count ?? 0) == 0
    }
}
