//
//  AuthError.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 9/26/25.
//
import Foundation


enum AuthError: LocalizedError {
    // MARK: - Validation
    case invalidEmail
    case invalidPasswordEmpty
    case invalidPasswordTooShort
    case passwordsDoNotMatch
    case emptyField(String) // e.g. "Username"
    
    // MARK: - Supabase / Backend
    case emailNotConfirmed
    case emailAlreadyRegistered
    case userNotFound
    case wrongPassword
    case sessionExpired
    case networkError
    case serverError
    case tooManyRequests
    
    
    // MARK: - Generic
    case custom(String)
    case defaultError
    case noRefreshToken
    
    // MARK: - Title
    var title: String {
        switch self {
        case .invalidEmail: return "Invalid Email"
        case .invalidPasswordEmpty: return "Empty Password"
        case .invalidPasswordTooShort: return "Password Too Short"
        case .passwordsDoNotMatch: return "Passwords Don’t Match"
        case .emptyField(let field): return "\(field) Missing"
            
        case .emailNotConfirmed: return "Email Not Confirmed"
        case .emailAlreadyRegistered: return "Email Already Registered"
        case .userNotFound: return "User Not Found"
        case .wrongPassword: return "Incorrect Password"
        case .sessionExpired: return "Session Expired"
        case .networkError: return "Network Error"
        case .serverError: return "Server Error"
        case .tooManyRequests: return "Too Many Attempts"
            
        case .custom: return "Error"
        case .defaultError: return "Unknown Error"
        case .noRefreshToken:
            return "No refresh token. Please try logging in again."
        }
    }
    
    // MARK: - Message
    var message: String {
        switch self {
        case .invalidEmail:
            return "Your email address is not valid. Make sure it includes '@' and a domain, like 'example@mail.com'."
        case .invalidPasswordEmpty:
            return "Please enter your password."
        case .invalidPasswordTooShort:
            return "Password must be at least 6 characters long."
        case .passwordsDoNotMatch:
            return "The passwords you entered do not match. Please try again."
        case .emptyField(let field):
            return "Please enter your \(field.lowercased())."
            
        case .emailNotConfirmed:
            return "We sent a confirmation link to your email. Please confirm before logging in."
        case .emailAlreadyRegistered:
            return "This email is already registered. Try logging in instead."
        case .userNotFound:
            return "No account found with this email."
        case .wrongPassword:
            return "The password you entered is incorrect."
        case .sessionExpired:
            return "Your session has expired. Please log in again."
        case .networkError:
            return "Please check your internet connection and try again."
        case .serverError:
            return "Our servers are having trouble. Please try again later."
        case .tooManyRequests:
            return "Too many login attempts. Please wait a moment and try again."
            
        case .custom(let error):
            return error
        case .defaultError:
            
            return "Something went wrong. Please try again later."
        case .noRefreshToken:
            return "No refresh token. Please try logging in again."
        }
    }
    
    var errorDescription: String? { message }
   static func mapSupabaseError(_ error: Error) -> AuthError {
        let message = error.localizedDescription.lowercased()
        
        if message.contains("invalid login credentials") {
            return .wrongPassword
        } else if message.contains("email not confirmed") {
            return .emailNotConfirmed
        } else if message.contains("user not found") {
            return .userNotFound
        } else if message.contains("already registered") {
            return .emailAlreadyRegistered
        } else if message.contains("network") {
            return .networkError
        }
        return .custom(error.localizedDescription)
    }
}


struct SimpleError: Error {
    let message: String
}
