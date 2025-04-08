//
//  WorkoutDB.swift
//  SupaSet
//
//  Created by Rishi Garg on 4/2/25.
//

import FirebaseFirestore
import Foundation
// Matches the 'workouts' collection document (Nested Structure)
struct WorkoutDB_Nested: Identifiable, Codable {
    @DocumentID var id: String? // Populated by Firestore upon creation using .document()
    var userID: String // ID of the user who created it
    var name: String
    var date: Timestamp
    var endTime: Timestamp?
    var isFinished: Bool
    var notes: String? // Changed from String to String? to match Workout.swift
    var isPublic: Bool = true // Added based on fan-out logic
    var duration: TimeInterval? // Example: store if needed
    var totalVolume: Double?   // Example: store if needed


}
// Nested struct for exercises within a workout
struct WorkoutExerciseDB: Codable, Hashable {
    // Removed UUID id, order within array is sufficient or use exerciseID if needed for lookup
    var exerciseID: String // Reference to the 'exercises' collection or standardized ID
    var exerciseName: String? // Denormalized for easier display, optional
    var order: Int
    var notes: String?
    var sets: [ExerciseSetDB] = []
}

// Nested struct for sets within an exercise
struct ExerciseSetDB: Codable, Hashable {
    // Removed UUID id, order within array is sufficient
    var reps: Int
    var weight: Double
    var type: String // Store rawValue of SetType enum
    var rpe: Double?
    var notes: String?
    var order: Int
    var isDone: Bool

    // Initializer from SwiftData ExerciseSet
    // init(from exerciseSet: ExerciseSet) {
    //     self.reps = exerciseSet.reps
    //     self.weight = exerciseSet.weight
    //     self.type = exerciseSet.type.rawValue
    //     self.rpe = exerciseSet.rpe
    //     self.notes = exerciseSet.notes?.isEmpty == false ? exerciseSet.notes : nil
    //     self.order = exerciseSet.order
    //     self.isDone = exerciseSet.isDone
    // }
}
