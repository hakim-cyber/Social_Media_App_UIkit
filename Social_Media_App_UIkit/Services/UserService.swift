//
//  UserService.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 10/24/25.
//
import Foundation
import Supabase

final class UserService {
    private let client: SupabaseClient

    init(client: SupabaseClient = SupabaseManager.shared.client) {
        self.client = client
    }

    /// Fetch minimal profile for feed author chips / cells
    func fetchUserSummary(id: UUID) async throws -> UserSummary {
        try await client
            .from("users")
            .select("id, username, full_name, avatar_url, is_verified")
            .eq("id", value: id.uuidString)
            .single()
            .execute()
            .value
    }
}
