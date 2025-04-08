// User.swift
import Foundation
import FirebaseFirestore
// Represents the full user document in Firestore /users/{userID}
struct User: Codable, Identifiable, Equatable, Hashable { // Added Identifiable, Equatable
    @DocumentID var docId: String? // Use DocumentID to capture Firestore ID
    let id: String // This should match the Firestore Document ID (Auth UID)
    var email: String? // Email might not always be present depending on auth method
    var fullName: String
    var bio: String?
    var isPublic: Bool = false // Default to false? Decide your default privacy
    var profilePicUrl: String? // Renamed from profileImage for clarity (URL string)
    var followingCount: Int = 0
    var followerCount: Int = 0
    // Use FieldValue.serverTimestamp() for these on creation/update
    @ServerTimestamp var createdAt: Timestamp?
    @ServerTimestamp var updatedAt: Timestamp?
    // Conformance to Identifiable using the Firestore document ID
    var documentID: String { docId ?? id }

    // Coding keys if needed (e.g., if Firestore fields differ)
    // enum CodingKeys: String, CodingKey { ... }

     // Add Equatable conformance based on ID
     static func == (lhs: User, rhs: User) -> Bool {
         lhs.id == rhs.id
     }
}
