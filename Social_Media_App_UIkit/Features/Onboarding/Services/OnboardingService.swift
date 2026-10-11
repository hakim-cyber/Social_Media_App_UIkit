//
//  OnboardingService.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 9/28/25.
//

import Foundation

protocol OnboardingServicing {
    var hasSeenWelcome: Bool { get }
    func setHasSeenWelcome()
    func resetHasSeenWelcome()
}

final class OnboardingService: OnboardingServicing {
    private let defaults: UserDefaults

    init(defaults: UserDefaults) {
        self.defaults = defaults
    }
    
    private enum Keys {
        static let hasSeenWelcome = "hasSeenWelcome"
    }
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
