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
        let svc = SupabaseStorageService()

        let uniqueName = "\(UUID().uuidString).jpg"
        // unikaldır => upsert false
        let res = try await svc.uploadImage(
            image,
            userId: userId,
            bucket: .avatars,
            fileName: "avatars/\(uniqueName)",
            jpegQuality: 0.7,
            upsert: false,
            publicBucket: true
        )

        return (res.path, res.url.absoluteString)
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

       
        let current: UserProfile = try await supabase
            .from("users")
            .select()
            .eq("id", value: user.id.uuidString)
            .single()
            .execute()
            .value

        let oldAvatarUrl = current.avatar_url
        let oldPath = oldAvatarUrl.flatMap { extractStoragePath(from: $0, bucket: "avatars") }

       
        var newAvatarUrl: String? = current.avatar_url
        var newUploadedPath: String? = nil

        if let avatarImage {
            let (path, url) = try await uploadProfileAvatar(avatarImage, userId: user.id)
            newUploadedPath = path
            newAvatarUrl = url
        } else {
          
            newAvatarUrl = nil
        }

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
            avatar_url: newAvatarUrl
        )

        do {
           
            let updated: UserProfile = try await supabase
                .from("users")
                .update(payload, returning: .representation)
                .eq("id", value: user.id.uuidString)
                .select()
                .single()
                .execute()
                .value

           
            if let oldPath {
                // əgər yeni upload etdinsə, köhnə ilə eyni olma ehtimalı çox azdır (unikal)
                _ = try? await supabase.storage.from("avatars").remove(paths: [oldPath])
            }

            return updated

        } catch {
            if let newUploadedPath {
                _ = try? await supabase.storage.from("avatars").remove(paths: [newUploadedPath])
            }

            let ns = error as NSError
            if ns.code == 409 { throw ProfileCreateError.usernameTaken }
            throw ProfileCreateError.unknown(ns.localizedDescription)
        }
    }
}

extension ProfileService{
    private func extractStoragePath(from avatarUrl: String, bucket: String) -> String? {
        guard let url = URL(string: avatarUrl) else { return nil }

       
        let s = url.absoluteString

        let publicKey = "/storage/v1/object/public/\(bucket)/"
        if let range = s.range(of: publicKey) {
            let after = s[range.upperBound...]
            return String(after.split(separator: "?").first ?? "")
        }

        let signedKey = "/storage/v1/object/sign/\(bucket)/"
        if let range = s.range(of: signedKey) {
            let after = s[range.upperBound...]
            return String(after.split(separator: "?").first ?? "")
        }

        return nil
    }
}
