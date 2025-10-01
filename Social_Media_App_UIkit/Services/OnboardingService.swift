//
//  OnboardingService.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 9/28/25.
//

import UIKit
import Supabase

final class OnboardingService {
    private let defaults = UserDefaults.standard
    
    private enum Keys {
        static let hasSeenWelcome = "hasSeenWelcome"
    }
    
    private let supabase = SupabaseManager.shared.client
    
    var hasSeenWelcome: Bool {
        defaults.bool(forKey: Keys.hasSeenWelcome)
    }
    
    func setHasSeenWelcome() {
        defaults.set(true, forKey: Keys.hasSeenWelcome)
    }
    
    func resetHasSeenWelcome() {
        defaults.removeObject(forKey: Keys.hasSeenWelcome)
    }
    
    func checkIfUserHasProfile() async throws -> Bool {
        // Ensure we have a logged-in user
        guard let userId = supabase.auth.currentUser?.id else {
            return false
        }
        
        // Perform a HEAD request with count to efficiently check existence
        let response = try await supabase
            .from("users")
            .select("id", head: true, count: .exact)
            .eq("id", value: userId)
            .execute()
        
        // If count > 0, a row exists
        return (response.count ?? 0) > 0
    }
}
