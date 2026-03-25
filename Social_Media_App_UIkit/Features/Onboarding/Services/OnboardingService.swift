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
  
}
