//
//  ProfileCreateError.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 10/7/25.
//


import UIKit

enum ProfileCreateError: Error, LocalizedError {
    case notAuthenticated
    case usernameTaken
    case unknown(String)
    // Profile Creation Errors
    case profileCreationFailed
    case profileAlreadyExists
    case bioTooLong
    case invalidImageData
    case uploadFailed

    var errorDescription: String? {
        switch self {
        case .notAuthenticated: return "No signed-in user."
        case .usernameTaken:    return "This username is already taken."
        case .profileCreationFailed:
            return "Failed to create user profile. Please try again."
        case .profileAlreadyExists:
            return "Profile already exists for this user."
        case .bioTooLong:
            return "Bio must be 150 characters or less."
        case .invalidImageData:
            return "Invalid image format. Please try another image."
        case .uploadFailed:
            return "Failed to upload image. Please try again."
        case .unknown(let m):   return m
        }
    }
}
