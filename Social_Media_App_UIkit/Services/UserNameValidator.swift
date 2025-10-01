//
//  UserNameValidator.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 10/2/25.


import Foundation
import Supabase



final class UsernameValidator {
    private let supabase = SupabaseManager.shared.client
    
    // Validate format
    func isValidFormat(_ username: String) -> (Bool, String?) {
        let trimmed = username.trimmingCharacters(in: .whitespaces)
        
        if trimmed.count < 3 {
            return (false, "Username must be at least 3 characters")
        }
        
        if trimmed.count > 20 {
            return (false, "Username must be less than 20 characters")
        }
        
        let pattern = "^[a-zA-Z][a-zA-Z0-9_]*$"
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSRange(trimmed.startIndex..., in: trimmed)
        
        if regex?.firstMatch(in: trimmed, range: range) == nil {
            return (false, "Only letters, numbers, and underscores allowed")
        }
        
        return (true, nil)
    }
    
    // Check if username is taken
    func isAvailable(_ username: String) async throws -> Bool {
        let response = try await supabase
            .from("users")
            .select("id", count: .exact)
            .ilike("username", pattern: username)
            .execute()
        
        return (response.count ?? 0) == 0
    }
    
    // Full validation
    func validate(_ username: String) async -> (Bool, String?) {
        // Check format first
        let (isValid, error) = isValidFormat(username)
        guard isValid else {
            return (false, error)
        }
        
        // Check availability
        do {
            let available = try await isAvailable(username)
            return available ? (true, nil) : (false, "Username already taken")
        } catch {
            return (false, "Could not check username")
        }
    }
}
