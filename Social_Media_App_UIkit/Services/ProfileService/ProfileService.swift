//
//  ProfileService.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 10/4/25.
//

import Foundation
import Supabase
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

class ProfileService {
    private let supabase = SupabaseManager.shared.client
    
    func checkIfUserHasProfile() async throws -> Bool {
        // Ensure we have a logged-in user
        guard let userId = supabase.auth.currentUser?.id else {
            return false
        }
        struct Row: Decodable { let id: UUID }
        let rows: [Row] = try await supabase
            .from("users")
            .select("id")
            .eq("id", value: userId.uuidString)
            .limit(1)
            .execute()
            .value
        return !rows.isEmpty
    }
}

extension ProfileService {
    /// Creates a brand-new profile row in `public.users`.
    /// - Parameters:
    ///   - username: unique username (validated on the server)
    ///   - fullName: required full name
    ///   - bio: optional bio
    ///   - avatarImage: optional avatar image to upload; if provided, it is uploaded **before** insert
    /// - Returns: the created `UserProfile`
    func createNewProfile(
        username: String,
        fullName: String,
        bio: String?,
        avatarImage: UIImage?
    ) async throws -> UserProfile {

        // 1) Ensure we have a signed-in user
        let session = try await supabase.auth.session
        let user = session.user
        print(user.id.uuidString)
        // 2) Optional: upload avatar first; keep path so we can delete if insert fails
        var uploadedPath: String? = nil
        var avatarUrl: String? = nil

        print("Uploading avatar")
        if let avatarImage {
            do{
                
                let (path, avatarURL) = try await self.uploadProfileAvatar(avatarImage, userId: user.id)
                uploadedPath = path
                avatarUrl = avatarURL
            }catch{
                print(error)
                throw error
            }
        }
        print("uploaded avatar")
        let payload = UserProfileUpsert(
            id: user.id,
            email: user.email,
            username: username,
            full_name: fullName,
            bio: bio,
            avatar_url: avatarUrl
        )

        // 4) Insert (NOT upsert). If it fails, try to clean up the uploaded file.
        do {
            print("Creatig new profile")
            // Add `.select()` so the client decodes the returned representation.
            let created: UserProfile = try await supabase
                .from("users")
                .insert(payload, returning: .representation)
                .select()
                .single()
                .execute()
                .value
            print("created new profile")
            return created

        } catch {
            // best-effort cleanup if DB insert failed after we uploaded
            if let uploadedPath {
                _ = try? await supabase.storage.from("avatars").remove(paths: [uploadedPath])
            }
            print("error creating new profile")
            print(error)
            let ns = error as NSError
            if ns.code == 409 { throw ProfileCreateError.usernameTaken }
            throw ProfileCreateError.unknown(ns.localizedDescription)
        }
    }

    /// Upload profile avatar image
    func uploadProfileAvatar(_ image: UIImage, userId: UUID) async throws -> (path: String, publicUrl: String) {
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            throw ProfileCreateError.invalidImageData
        }
        // Versioned filename for cache-busting
           let fileName = "avatar.jpg"

           // Path INSIDE the bucket (no "avatars/" prefix). Must start with {auth.uid()} to satisfy folder-based Storage RLS.
        let filePath = "\(userId.uuidString.lowercased())/\(fileName)"
  
           // Upload (public bucket). Upsert lets the user replace their avatar.
           _ = try await supabase.storage
               .from("avatars")
               
               .upload(
                filePath,
                   data: imageData,
                options: FileOptions(contentType: "image/jpeg", upsert: true)
               )

           // Public URL (String; non-throwing)
           let publicURL: String = try supabase.storage
               .from("avatars")
               .getPublicURL(path: filePath)
               .absoluteString

           return (filePath, publicURL)
      
    }
}
