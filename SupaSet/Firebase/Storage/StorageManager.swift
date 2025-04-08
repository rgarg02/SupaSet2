//
//  StorageManager.swift
//  SupaSet
//
//  Created by Rishi Garg on 4/2/25. // Or your current date
//

import Foundation
import FirebaseStorage
import UIKit // Needed for UIImage compression

enum StorageError: Error {
    case invalidImageData
    case compressionFailed
    case uploadFailed(Error?)
    case downloadURLNotFound
}

final class StorageManager {
    static let shared = StorageManager()
    private init() {} // Private initializer for Singleton

    private let storage = Storage.storage().reference()

    // MARK: - Profile Images
    
    /// Generates the StorageReference for a user's profile picture.
    private func profileImageReference(userId: String) -> StorageReference {
        // Store images in a specific path, overwriting the previous one for simplicity
        storage.child("profile_images").child("\(userId).jpg")
    }
    
    /// Uploads profile image data to Firebase Storage.
    /// - Parameters:
    ///   - userId: The ID of the user.
    ///   - data: The raw image data (e.g., from PhotosPicker).
    ///   - compressionQuality: The compression quality for JPEG (0.0 to 1.0). Default is 0.75.
    /// - Returns: The downloadable URL of the uploaded image.
    /// - Throws: `StorageError` if upload fails or data is invalid.
    func uploadProfileImage(userId: String, data: Data, compressionQuality: CGFloat = 0.5) async throws -> URL {
        guard let image = UIImage(data: data) else {
            print("❌ StorageManager: Could not create UIImage from data.")
            throw StorageError.invalidImageData
        }

        // Compress the image
        guard let compressedData = image.jpegData(compressionQuality: compressionQuality) else {
            print("❌ StorageManager: Could not compress image data.")
            throw StorageError.compressionFailed
        }

        let ref = profileImageReference(userId: userId)
        let meta = StorageMetadata()
        meta.contentType = "image/jpeg"


        // Upload using async/await
        let metadata: StorageMetadata
        do {
            metadata = try await ref.putDataAsync(compressedData, metadata: meta)
            print("✅ StorageManager: Profile image uploaded successfully. Size: \(metadata.size / 1024) KB")
        } catch {
            print("❌ StorageManager: Failed to upload image data: \(error)")
            throw StorageError.uploadFailed(error)
        }

        // Get Download URL
        do {
            let downloadURL = try await ref.downloadURL()
            print("✅ StorageManager: Got download URL: \(downloadURL.absoluteString)")
            return downloadURL
        } catch {
            print("❌ StorageManager: Failed to get download URL: \(error)")
            // If URL fails, maybe delete the uploaded file? Or let it be orphaned.
            // try? await ref.delete()
            throw StorageError.downloadURLNotFound
        }
    }

    /// Deletes the profile image for a given user ID.
    /// - Parameter userId: The ID of the user whose profile image should be deleted.
    /// - Throws: An error if the deletion fails (often ignored if file didn't exist).
    func deleteProfileImage(userId: String) async throws {
        let ref = profileImageReference(userId: userId)
        do {
            try await ref.delete()
            print("✅ StorageManager: Deleted profile image for user \(userId)")
        } catch let error as NSError where error.domain == StorageErrorDomain && error.code == StorageErrorCode.objectNotFound.rawValue {
            // Handle file not found error gracefully (it's okay if it's already deleted)
            print("ℹ️ StorageManager: Profile image for user \(userId) not found, nothing to delete.")
        } catch {
            // Handle other errors
            print("❌ StorageManager: Error deleting profile image for user \(userId): \(error)")
            throw error // Re-throw other errors
        }
    }
}
