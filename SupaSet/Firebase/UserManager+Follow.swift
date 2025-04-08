//
//  UserManager+Follow.swift
//  SupaSet
//
//  Created by Rishi Garg on 4/3/25.
//
import FirebaseAuth
import FirebaseFirestore
extension UserManager {
    // MARK: - Following / Followers
    
    /// Follows a user using the Hybrid (Subcollections + Counters) approach.
    /// - Parameter userToFollowID: The ID of the user to follow.
    /// - Throws: An error if the user is not logged in, attempting to self-follow, or if the Firestore operation fails.
    func follow(userToFollowID: String) async throws {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "UserManager.Follow", code: 1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }
        
        guard currentUserID != userToFollowID else {
            print("⚠️ Attempted to self-follow.")
            // Optionally throw an error or just return
            // throw NSError(domain: "UserManager.Follow", code: 2, userInfo: [NSLocalizedDescriptionKey: "Cannot follow yourself"])
            return
        }
        
        // References to the main user documents
        let currentUserDocRef = usersCollection.document(currentUserID)
        let userToFollowDocRef = usersCollection.document(userToFollowID)
        
        // References to the subcollection documents
        // Document in current user's "following" subcollection, ID is the user being followed
        let followingDocRef = currentUserDocRef.collection("following").document(userToFollowID)
        // Document in the target user's "followers" subcollection, ID is the current user
        let followerDocRef = userToFollowDocRef.collection("followers").document(currentUserID)
        
        // Data for the relationship documents (can be empty or add a timestamp)
        let relationshipData = ["timestamp": FieldValue.serverTimestamp()] // Optional
        
        // --- Perform atomic batch write ---
        let batch = db.batch()
        
        // 1. Add userToFollowID to the current user's "following" subcollection
        batch.setData(relationshipData, forDocument: followingDocRef)
        
        // 2. Add currentUserID to the target user's "followers" subcollection
        batch.setData(relationshipData, forDocument: followerDocRef)
        
        // 3. Increment the current user's followingCount
        batch.updateData(["followingCount": FieldValue.increment(Int64(1))], forDocument: currentUserDocRef)
        
        // 4. Increment the target user's followerCount
        batch.updateData(["followerCount": FieldValue.increment(Int64(1))], forDocument: userToFollowDocRef)
        
        // Commit the batch
        do {
            try await batch.commit()
            try await getCurrentUser()
        } catch {
            throw error
        }
        // --- End batch write ---
    }
    /// Unfollows a user using the Hybrid (Subcollections + Counters) approach.
    /// - Parameter userToUnfollowID: The ID of the user to unfollow.
    /// - Throws: An error if the user is not logged in or if the Firestore operation fails.
    func unfollow(userToUnfollowID: String) async throws {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "UserManager.Unfollow", code: 1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }
        
        // Prevent self-unfollow (though logically less likely to be needed)
        guard currentUserID != userToUnfollowID else {
            throw NSError(domain: "UserManager.Unfollow", code: 1, userInfo: [NSLocalizedDescriptionKey: "Cannot unfollow self"])
            return
        }
        
        // References to the main user documents
        let currentUserDocRef = usersCollection.document(currentUserID)
        let userToUnfollowDocRef = usersCollection.document(userToUnfollowID)
        
        // References to the subcollection documents to be deleted
        let followingDocRef = currentUserDocRef.collection("following").document(userToUnfollowID)
        let followerDocRef = userToUnfollowDocRef.collection("followers").document(currentUserID)
        
        // --- Perform atomic batch write ---
        let batch = db.batch()
        
        // 1. Delete the document from the current user's "following" subcollection
        batch.deleteDocument(followingDocRef)
        
        // 2. Delete the document from the target user's "followers" subcollection
        batch.deleteDocument(followerDocRef)
        
        // 3. Decrement the current user's followingCount (ensure it doesn't go below zero server-side if needed, though increments handle this)
        batch.updateData(["followingCount": FieldValue.increment(Int64(-1))], forDocument: currentUserDocRef)
        
        // 4. Decrement the target user's followerCount
        batch.updateData(["followerCount": FieldValue.increment(Int64(-1))], forDocument: userToUnfollowDocRef)
        
        // Commit the batch
        do {
            try await batch.commit()
            // Refresh local user data to reflect the new count
            try await getCurrentUser()
        } catch {
            // Consider adding checks if counts go below zero - maybe query before decrement if strictness needed
            throw error
        }
        // --- End batch write ---
    }
    
    /// Checks if the current user is following a specific user.
    /// - Parameter otherUserID: The ID of the user to check.
    /// - Returns: `true` if the current user follows the other user, `false` otherwise. Returns `false` if not authenticated.
    /// - Throws: Firestore errors if the document check fails.
    func isFollowing(otherUserID: String) async throws -> Bool {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            // Not authenticated, cannot be following anyone
            return false
        }
        
        // No need to check for self - you don't follow yourself in this model
        if currentUserID == otherUserID { return false }
        
        // Check if the document exists in the current user's "following" subcollection
        let followingDocRef = usersCollection.document(currentUserID)
            .collection("following")
            .document(otherUserID)
        
        do {
            let documentSnapshot = try await followingDocRef.getDocument()
            return documentSnapshot.exists // True if the document exists, false otherwise
        } catch {
            // Re-throw the Firestore error
            throw error
        }
    }
    
    // MARK: - User Discovery
    
    /// Fetches a page of public user profiles from Firestore.
    /// - Parameters:
    ///   - pageSize: The maximum number of users to fetch per page.
    ///   - lastDocumentSnapshot: The snapshot of the last document from the previous page.
    ///                           Pass `nil` to fetch the first page.
    /// - Returns: A tuple containing an array of fetched `User` objects and the snapshot
    ///            of the last document in the array (or `nil` if no documents were fetched or
    ///            it's the end of the list).
    /// - Throws: Firestore errors if the query fails. Might require a composite index.
    func fetchPublicUsers(pageSize: Int, lastDocumentSnapshot: DocumentSnapshot? = nil) async throws -> (users: [User], lastSnapshot: DocumentSnapshot?) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
                    // Throw an error as fetching users 'other than self' requires knowing 'self'
                    throw NSError(domain: "UserManager.Discovery", code: 1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
                }
        // Base query: public users, ordered by creation date (newest first)
        // NOTE: Firestore might require you to create a composite index for this query
        // (isPublic == true, createdAt descending). Check your Firestore console logs/errors.
        var query: Query = usersCollection
            .whereField("isPublic", isEqualTo: true)
            .whereField(FieldPath.documentID(), isNotEqualTo: currentUserID) // Filter out current user
            .order(by: FieldPath.documentID()) // Firestore often requires ordering by the field in the first inequality filter
        // Apply cursor for pagination if lastDocumentSnapshot is provided
        if let lastSnapshot = lastDocumentSnapshot {
            query = query.start(afterDocument: lastSnapshot)
        }
        
        // Apply the page size limit
        query = query.limit(to: pageSize)
        
        do {
            let snapshot = try await query.getDocuments()
            let documents = snapshot.documents
            // Decode documents into User objects
            // Using compactMap to safely ignore documents that fail decoding
            let users = documents.compactMap { doc -> User? in
                do {
                    return try doc.data(as: User.self)
                } catch {
                    return nil
                }
            }
            
            // Get the snapshot of the last document in THIS batch for the next page query
            let lastSnapshotForNextPage = documents.last
            // remove self from the users array
            if let currentUserID = Auth.auth().currentUser?.uid {
                return (users: users.filter { $0.id != currentUserID }, lastSnapshot: lastSnapshotForNextPage)
            }
            return (users: users, lastSnapshot: lastSnapshotForNextPage)
        } catch {
            // Handle specific errors if needed (e.g., index missing)
            throw error
        }
    }
}
