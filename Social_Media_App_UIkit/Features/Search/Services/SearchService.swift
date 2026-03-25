//
//  SearchService.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 12/27/25.
//

import Supabase
import Foundation

class SearchService{
 private let supabase = SupabaseManager.shared.client
        
    func searchUsers(
           query: String,
           limit: Int = 10
       ) async throws -> [UserSummary] {

           let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
           guard !q.isEmpty else { return [] }

           let params: [String: AnyJSON] = [
               "query_param": try AnyJSON(q),
               "limit_param":try AnyJSON(Double(limit))
               // current_user_id uses DEFAULT auth.uid()
           ]

           let users: [UserSummary] = try await supabase
               .rpc("search_users", params: params)
               .execute()
               .value

           return users
       }

}
