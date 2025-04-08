// UserManager.swift
import Foundation
import FirebaseFirestore
import SwiftUI // Needed for UIImage if you handle uploads here
import FirebaseAuth

@Observable
class UserManager {
    var user: User?
    internal var db: Firestore {
        Firestore.firestore()
    }
    // Root Collection References
    internal var usersCollection: CollectionReference { db.collection("users") }
    
    // MARK: - User Profile CRUD (Existing Functions)
    
    // Create initial user document
    func createUser(email: String?, fullName: String, bio: String?, isPublic: Bool = true, newProfileImageData: Data?) async throws {
        guard let id = Auth.auth().currentUser?.uid else {
            print("❌ Cannot create user: No authenticated user found.")
            throw NSError(domain: "UserManager.Create", code: 1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }
        // Check if user already exists to prevent overwriting accidentally
        guard try await !userExists(id: id) else {
            print("ℹ️ User document for \(id) already exists. Skipping creation.")
            // Optionally update existing data here if desired
            return
        }
        var imageUrlNew: String? = nil
        if let imageData = newProfileImageData {
            do {
                let imageUrl = try await StorageManager.shared.uploadProfileImage(userId: id, data: imageData)
                imageUrlNew = imageUrl.absoluteString // Store the URL string
            } catch {
                throw error
            }
        }
        // Ensure User struct matches your Firestore data model definition
        let user = User(id: id, email: email, fullName: fullName, bio: bio, isPublic: isPublic, profilePicUrl: imageUrlNew, followingCount: 0, followerCount: 0, createdAt: nil, updatedAt: nil /* Add other fields as needed */)
        
        do {
            try usersCollection.document(id).setData(from: user, merge: false) // Use merge: false for initial creation
            print("✅ User document created for \(id)")
        } catch {
            print("❌ Error creating user document for \(id): \(error)")
            throw error
        }
    }
    
    // Check if user exists
    func userExists(id: String) async throws -> Bool {
        let docSnapshot = try await usersCollection.document(id).getDocument()
        return docSnapshot.exists
    }
    
    // Get current authenticated user's profile
    func getCurrentUser() async throws {
        guard let currentUser = Auth.auth().currentUser else {
            throw NSError(domain: "UserManager", code: 3, userInfo: [NSLocalizedDescriptionKey: "No current user authenticated"])
        }
        self.user = try await getUser(id: currentUser.uid)
    }
    
    // Get specific user data
    func getUser(id: String) async throws -> User {
        do {
            let user = try await usersCollection.document(id).getDocument(as: User.self)
            return user
        } catch {
            print("❌ Error fetching user \(id): \(error)")
            // Handle specific errors like document not found if needed
            throw NSError(domain: "UserManager", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch or decode user data for ID: \(id). Error: \(error.localizedDescription)"])
        }
    }
    
    func updateUserProfile(fullName: String?, bio: String??, isPublic: Bool?, newProfileImageData: Data?) async throws {
        guard let id = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "UserManager.Update", code: 1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }
        
        var updateData: [String: Any] = [:]
        var hasChanges = false
        
        // 1. Handle Image Upload First (if provided)
        var newImageUrlString: String? = nil
        if let imageData = newProfileImageData {
            do {
                let imageUrl = try await StorageManager.shared.uploadProfileImage(userId: id, data: imageData)
                newImageUrlString = imageUrl.absoluteString // Store the URL string
            } catch {
                throw error
            }
        }
        
        // 2. Prepare Firestore Update Data
        if let urlString = newImageUrlString {
            updateData["profilePicUrl"] = urlString
            hasChanges = true
        }
        
        if let name = fullName {
            updateData["fullName"] = name
            hasChanges = true
        }
        
        // Handle bio update: .none means no change, .some(nil) means set to null, .some("text") means set to text
        if case .some(let bioValue) = bio {
            updateData["bio"] = bioValue // Pass nil or the string directly
            hasChanges = true
        }
        
        if let pub = isPublic {
            updateData["isPublic"] = pub
            hasChanges = true
        }
        
        if hasChanges {
            updateData["updatedAt"] = FieldValue.serverTimestamp()
        } else {
            return
        }
        
        do {
            try await usersCollection.document(id).updateData(updateData)
            try await getCurrentUser()
            
        } catch {
            throw error
        }
    }
    
    func deleteUserData(id: String) async throws {
        do {
            try await usersCollection.document(id).delete()
            print("✅ User document deleted for \(id)")
            // ALSO delete associated storage data
            try? await StorageManager.shared.deleteProfileImage(userId: id) // Attempt to delete profile pic
        } catch {
            print("❌ Error deleting user document for \(id): \(error)")
            throw error
        }
    }
    
}


