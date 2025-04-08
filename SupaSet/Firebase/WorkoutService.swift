import Foundation
import FirebaseFirestore
import FirebaseAuth


// MARK: - Workout Service (Focusing on Upload)
struct WorkoutService {
    /// Uploads a Workout object (converted to WorkoutFS) to Firestore as a single nested document.
    /// - Parameters:
    ///   - workout: The original SwiftData Workout object.
    ///   - isPublic: Boolean indicating if the workout should be public.
    /// - Returns: The Firestore document ID of the newly created workout.
    /// - Throws: An error if the user is not logged in or if the upload fails.
    static func uploadWorkout(_ workout: Workout, isPublic: Bool) async throws -> String {
        // Ensure user is logged in
        guard let userId = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "WorkoutService", code: 10, userInfo: [NSLocalizedDescriptionKey: "User not logged in for workout upload"])
        }
        print("Starting workout upload for user \(userId)...")

        // 1. Convert the SwiftData Workout model to the Firestore Codable WorkoutFS model
        let workoutFS = WorkoutFS(from: workout, userID: userId, isPublic: isPublic)

        // 2. Get a reference to the Firestore "workouts" collection and the specific document ID
        let workoutDocRef = Firestore.firestore().collection("workouts").document()

        // 3. Attempt to set the data using the Codable struct
        do {
            // Directly encode the WorkoutFS struct. FirestoreSwift handles the conversion.
            // We are using the workoutFS.id as the document ID.
            try workoutDocRef.setData(from: workoutFS, merge: false) // Use merge: false to ensure it's a new doc

            // Optional: Trigger feed fan-out logic here if needed (consider Cloud Functions)
            // Task.detached { ... call fan-out ... }

            return workoutDocRef.documentID // Return the ID used for the document

        } catch {
            print("❌ Error uploading workout data to Firestore doc ID \(workoutDocRef.documentID): \(error)")
            // Provide more detail on encoding errors
            if let encodingError = error as? EncodingError {
                 print("❌ Encoding Error Details: \(encodingError)")
            }
            throw error // Re-throw the error to be handled by the caller
        }
    }
    static func fetchPublicWorkouts() async throws -> [WorkoutFS] {
        let querySnapshot = try await Firestore.firestore().collection("workouts")
            .whereField("isPublic", isEqualTo: true)
            .limit(to: 10)
            .getDocuments()
        return querySnapshot.documents.compactMap { document in
            try? document.data(as: WorkoutFS.self)
        }
    }
}

// Assume your SwiftData models (Workout, WorkoutExercise, ExerciseSet, SetType) are defined elsewhere.
// Make sure the SetType enum in your SwiftData model has a rawValue of type String.
