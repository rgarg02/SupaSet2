//
//  SetTypeFS.swift
//  SupaSet
//
//  Created by Rishi Garg on 4/2/25.
//


import Foundation
import FirebaseFirestore // Make sure to import FirebaseFirestore


// MARK: - Firestore Codable Structs (Defined Previously)
// Ensure these structs (WorkoutFS, WorkoutExerciseFS, ExerciseSetFS, SetTypeFS)
// are accessible in the scope where WorkoutService is used.

// Example (definitions from previous response):
enum SetTypeFS: String, Codable, Hashable {
    case warmup, working, drop, failure
}

struct ExerciseSetFS: Codable, Identifiable, Hashable {
    @DocumentID var docId: String?
    var id: String
    var reps: Int
    var weight: Double
    var type: SetTypeFS
    var rpe: Double?
    var notes: String?
    var order: Int
    var isDone: Bool

    // Initializer from SwiftData Model (keep this accessible)
    init(from set: ExerciseSet) {
        self.id = set.id.uuidString
        self.reps = set.reps
        self.weight = set.weight
        self.type = SetTypeFS(rawValue: set.type.rawValue) ?? .working
        self.rpe = set.rpe
        self.notes = set.notes
        self.order = set.order
        self.isDone = set.isDone
    }
    // Add other initializers if needed
}

struct WorkoutExerciseFS: Codable, Identifiable, Hashable {
    @DocumentID var docId: String?
    var id: String
    var exerciseID: String // Reference to ExerciseEntity ID
    var order: Int
    var notes: String?
    var sets: [ExerciseSetFS] // Nested sets

    // Initializer from SwiftData Model (keep this accessible)
    init(from workoutExercise: WorkoutExercise) {
        self.id = workoutExercise.id.uuidString
        self.exerciseID = workoutExercise.exerciseID
        self.order = workoutExercise.order
        self.notes = workoutExercise.notes
        self.sets = workoutExercise.sets.map(ExerciseSetFS.init)
    }
     // Add other initializers if needed
}

struct WorkoutFS: Codable, Identifiable, Hashable {
    @DocumentID var docId: String? // Use this if you want Firestore to manage the ID field upon fetch
    var id: String // Manually assigned UUID string, used as document ID upon creation
    var userID: String
    var name: String
    var date: Timestamp
    var endTime: Timestamp?
    var isFinished: Bool
    var notes: String? // Make optional if notes can be empty
    var isPublic: Bool = true
    @ServerTimestamp var createdAt: Timestamp?
    @ServerTimestamp var updatedAt: Timestamp?
    var exercises: [WorkoutExerciseFS] // Nested exercises

    // Initializer from SwiftData Model (keep this accessible)
    init(from workout: Workout, userID: String, isPublic: Bool) {
        self.id = workout.id.uuidString // Use the SwiftData UUID as the Firestore ID
        self.userID = userID
        self.name = workout.name
        self.date = Timestamp(date: workout.date)
        self.endTime = workout.endTime != nil ? Timestamp(date: workout.endTime!) : nil
        self.isFinished = workout.isFinished
        self.notes = workout.notes.isEmpty ? nil : workout.notes // Store nil if empty
        self.isPublic = isPublic // Use the passed-in value
        self.exercises = workout.exercises.sorted { $0.order < $1.order }.map(WorkoutExerciseFS.init) // Ensure exercises are sorted before mapping
        // createdAt and updatedAt are handled by @ServerTimestamp
    }
     // Add other initializers if needed
}
