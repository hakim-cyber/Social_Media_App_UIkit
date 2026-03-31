//
//  ProfileAvatarService.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 3/31/26.
//
import Supabase
import UIKit


final class ProfileAvatarService {
    private let supabase = SupabaseManager.shared.client
    private let storage = SupabaseStorageService()

    func upload(_ image: UIImage, userId: UUID) async throws -> (path: String, publicURL: String) {
        let uniqueName = "\(UUID().uuidString).jpg"

        let result = try await storage.uploadImage(
            image,
            userId: userId,
            bucket: .avatars,
            fileName: "avatars/\(uniqueName)",
            jpegQuality: 0.7,
            upsert: false,
            publicBucket: true
        )

        return (result.path, result.url.absoluteString)
    }

    func removeAvatar(from publicURL: String?) async {
        guard
            let publicURL,
            let path = extractStoragePath(from: publicURL, bucket: "avatars")
        else { return }

        _ = try? await supabase.storage.from("avatars").remove(paths: [path])
    }

    func rollbackUpload(path: String?) async {
        guard let path else { return }
        _ = try? await supabase.storage.from("avatars").remove(paths: [path])
    }

    private func extractStoragePath(from urlString: String, bucket: String) -> String? {
        guard let url = URL(string: urlString) else { return nil }

        let value = url.absoluteString
        let publicKey = "/storage/v1/object/public/\(bucket)/"
        if let range = value.range(of: publicKey) {
            return String(value[range.upperBound...].split(separator: "?").first ?? "")
        }

        let signedKey = "/storage/v1/object/sign/\(bucket)/"
        if let range = value.range(of: signedKey) {
            return String(value[range.upperBound...].split(separator: "?").first ?? "")
        }

        return nil
    }
}
