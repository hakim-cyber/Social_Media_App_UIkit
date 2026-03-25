//
//  SupabaseStorageService.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 10/7/25.
//
import UIKit
import Supabase

enum StorageBucket: String {
    case avatars = "avatars"
    case postImages = "post_images"
}

struct UploadResult: Sendable {
    let path: String        // e.g. "<uid>/avatar.jpg" or "<uid>/post_<uuid>.jpg"
    let url: URL            // public or signed URL based on config
}
struct SupabaseStorageService {
    private let client = SupabaseManager.shared.client
    private let storage: SupabaseStorageClient

    init() {
        self.storage = client.storage
       
    }

    /// Uploads a UIImage to a Storage bucket under {userId}/... and returns (path, url).
    /// - Parameters:
    ///   - image: Source UIImage
    ///   - userId: current auth uid (UUID)
    ///   - bucket: target bucket (avatars / post_images)
    ///   - fileName: optional fixed file name (useful for avatars); otherwise generated
    ///   - jpegQuality: 0...1
    ///   - upsert: true to replace (avatars), false to prevent overwrite (posts)
    ///   - publicBucket: if true -> getPublicURL, else -> signed URL with expiry
    ///   - signedURLExpiry: seconds for signed URL validity (ignored for public buckets)
    func uploadImage(
        _ image: UIImage,
        userId: UUID,
        bucket: StorageBucket,
        fileName: String? = nil,
        jpegQuality: CGFloat = 0.8,
        upsert: Bool,
        publicBucket: Bool,
        signedURLExpiry: TimeInterval = 60 * 60 // 1 hour
    ) async throws -> UploadResult {

        guard let data = image.jpegData(compressionQuality: jpegQuality) else {
            throw NSError(domain: "UploadError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid image data"])
        }

        // Build path: {uid}/<filename>
        let uid = userId.uuidString.lowercased()
        let name: String = fileName ?? "img_\(UUID().uuidString).jpg"
        let path = "\(uid)/\(name)"

        // Upload
        try await storage
            .from(bucket.rawValue)
            .upload(
                path,
                data: data,
                options: FileOptions(contentType: "image/jpeg", upsert: upsert)
            )

        // URL
        if publicBucket {
            // Public buckets: stable public URL
            let publicURL = try storage
                .from(bucket.rawValue)
                .getPublicURL(path: path)
           
            return .init(path: path, url: publicURL)
        } else {
            // Private buckets: generate a signed URL
            let signed = try await storage
                .from(bucket.rawValue)
                .createSignedURL(path: path, expiresIn: Int(signedURLExpiry))
         
            return .init(path: path, url: signed)
        }
    }
}
