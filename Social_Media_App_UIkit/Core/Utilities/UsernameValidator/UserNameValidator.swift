//
//  UserNameValidator.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 10/2/25.


import Foundation
import Supabase

protocol UsernameValidating {
    func validate(_ username: String) async -> (Bool, UserNameValidationError?)
}

struct UsernameValidator: UsernameValidating {
    private let api: UsernameAPI

    init(api: UsernameAPI) {
        self.api = api
    }
    
    // Full validation
    func validate(_ username: String) async -> (Bool, UserNameValidationError?) {
        // Check format first
        let (isValid, error) = isValidFormat(username)
        guard isValid else {
            return (false, error)
        }
        
        // Check availability
        do {
            let available = try await api.isUsernameAvailable(username)
            return available ? (true, nil) : (false, .usernameTaken)
        } catch {
            return (false,.usernameCheckErorr)
        }
    }
    
    // Validate format
   private func isValidFormat(_ username: String) -> (Bool, UserNameValidationError?) {
        let trimmed = username.trimmingCharacters(in: .whitespaces)
        
        if trimmed.count < 3 {
            return (false,.usernameShort)
        }
        
        if trimmed.count > 20 {
            return (false, .usernameTooLong)
        }
        
        let pattern = "^[a-zA-Z][a-zA-Z0-9_]*$"
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSRange(trimmed.startIndex..., in: trimmed)
        
        if regex?.firstMatch(in: trimmed, range: range) == nil {
            return (false, .usernameInvalidCharacter)
        }
        
        return (true, nil)
    }
    
   
}

enum UserNameValidationError:LocalizedError{
    case usernameShort
    case usernameTooLong
    case usernameInvalidCharacter
    case usernameCheckErorr
    case usernameTaken
    
    var errorDescription: String? {
        switch self {
        case .usernameShort:
            return "Username must be at least 3 characters"
        case .usernameTooLong:
            return "Username must be less than 20 characters"
        case .usernameInvalidCharacter:
            return "Only letters, numbers, and underscores allowed"
        case .usernameCheckErorr:
            return "Could not check username"
        case .usernameTaken:
            return "Username is already taken"
        }
    }
}
