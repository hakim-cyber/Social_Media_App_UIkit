//
//  ProfileService.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 10/4/25.
//

import Foundation
import Supabase
import UIKit


class ProfileService {
    private let supabase = SupabaseManager.shared.client
    private let avatarService = ProfileAvatarService()
    
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
    func fetchUserProfile(id: UUID) async throws -> UserProfile {
        try await supabase
            .from("users")
            .select()
            .eq("id", value: id.uuidString)
            .single()
            .execute()
            .value
    }
    func fetchProfileCounts(userId: UUID) async throws -> ProfileCounts {
            // call RPC or query view
            let res: ProfileCounts = try await supabase
                .rpc("get_profile_counts", params: ["user_id_param": userId.uuidString])
                .execute()
                .value
            return res
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
        let session = try await supabase.auth.session
        let user = session.user
        let uploadedAvatar: (path: String, publicURL: String)?
        if let avatarImage {
            uploadedAvatar = try await avatarService.upload(avatarImage, userId: user.id)
        } else {
            uploadedAvatar = nil
        }

        do {
            return try await insertProfileRow(
                id: user.id,
                email: user.email,
                username: username,
                fullName: fullName,
                bio: bio,
                avatarURL: uploadedAvatar?.publicURL
            )
        } catch {
            await avatarService.rollbackUpload(path: uploadedAvatar?.path)
            throw mapProfileError(error)
        }
    }
}


extension ProfileService{
    func updateProfile(
        username: String,
        fullName: String,
        bio: String?,
        avatarImage: UIImage?
    ) async throws -> UserProfile {
        let session = try await supabase.auth.session
        let user = session.user
        let current = try await fetchUserProfile(id: user.id)
        let uploadedAvatar: (path: String, publicURL: String)?
        if let avatarImage {
            uploadedAvatar = try await avatarService.upload(avatarImage, userId: user.id)
        } else {
            uploadedAvatar = nil
        }
        let avatarURL = avatarImage == nil ? nil : uploadedAvatar?.publicURL

        do {
            let updated = try await updateProfileRow(
                userId: user.id,
                username: username,
                fullName: fullName,
                bio: bio,
                avatarURL: avatarURL
            )
            await avatarService.removeAvatar(from: current.avatar_url)
            return updated
        } catch {
            await avatarService.rollbackUpload(path: uploadedAvatar?.path)
            throw mapProfileError(error)
        }
    }
}

extension ProfileService{
    private func insertProfileRow(
        id: UUID,
        email: String?,
        username: String,
        fullName: String,
        bio: String?,
        avatarURL: String?
    ) async throws -> UserProfile {
        let payload = UserProfileUpsert(
            id: id,
            email: email,
            username: username,
            full_name: fullName,
            bio: bio,
            avatar_url: avatarURL
        )

        return try await supabase
            .from("users")
            .insert(payload, returning: .representation)
            .select()
            .single()
            .execute()
            .value
    }

    private func updateProfileRow(
        userId: UUID,
        username: String,
        fullName: String,
        bio: String?,
        avatarURL: String?
    ) async throws -> UserProfile {
        struct UserProfileUpdate: Encodable {
            let username: String
            let full_name: String
            let bio: String?
            let avatar_url: String?
        }

        let payload = UserProfileUpdate(
            username: username,
            full_name: fullName,
            bio: bio,
            avatar_url: avatarURL
        )

        return try await supabase
            .from("users")
            .update(payload, returning: .representation)
            .eq("id", value: userId.uuidString)
            .select()
            .single()
            .execute()
            .value
    }

    private func mapProfileError(_ error: Error) -> Error {
        let ns = error as NSError
        if ns.code == 409 {
            return ProfileCreateError.usernameTaken
        }
        return ProfileCreateError.unknown(ns.localizedDescription)
    }
}
