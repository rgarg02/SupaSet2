//
//  WorkoutModel.swift
//  SupaSet
//
//  Created by Rishi Garg on 11/6/24.
//

import Foundation
import SwiftData

@Model
final class Workout: Hashable {
    var id: UUID
    var name: String
    var date: Date
    var endTime : Date?
    var isFinished: Bool
    var notes: String?
    var duration: TimeInterval?
    var totalVolume: Double?  // Total weight lifted across all exercises
    @Relationship(deleteRule: .cascade) var exercises: [WorkoutExercise] = []
    
    init(
        name: String,
        date: Date = Date(),
        endTime: Date? = nil,
        isFinished: Bool = false,
        notes: String? = nil,
        duration: TimeInterval? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.date = date
        self.endTime = endTime
        self.isFinished = isFinished
        self.notes = notes
        self.duration = duration
    }
    
    // Computed property to calculate total volume
    func calculateTotalVolume() -> Double {
        exercises.reduce(0) { total, exercise in
            total + exercise.sets.reduce(0) { setTotal, set in
                setTotal + (set.weight * Double(set.reps))
            }
        }
    }
    
    // Hashable conformance
    static func == (lhs: Workout, rhs: Workout) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

@Model
final class WorkoutExercise: Hashable {
    var id: UUID
    var exercise: Exercise  // Reference to the exercise from your existing model
    var order: Int  // To maintain exercise order in workout
    var notes: String?
    @Relationship(deleteRule: .cascade) var sets: [ExerciseSet] = []
    @Relationship(inverse: \Workout.exercises) var workout: Workout?
    
    init(exercise: Exercise, order: Int = 0, notes: String? = nil) {
        self.id = UUID()
        self.exercise = exercise
        self.order = order
        self.notes = notes
    }
    
    // Computed property for total volume of this exercise
    var totalVolume: Double {
        sets.reduce(0) { total, set in
            total + (set.weight * Double(set.reps))
        }
    }
    
    // Hashable conformance
    static func == (lhs: WorkoutExercise, rhs: WorkoutExercise) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

@Model
final class ExerciseSet: Hashable {
    var id: UUID
    var reps: Int
    var weight: Double  // in whatever unit (lbs/kg) the user prefers
    var isWarmupSet: Bool
    var rpe: Int?  // Rate of Perceived Exertion (1-10)
    var notes: String?
    var order: Int  // To maintain set order in exercise
    var isDone: Bool
    @Relationship(inverse: \WorkoutExercise.sets) var workoutExercise: WorkoutExercise?
    
    init(
        reps: Int,
        weight: Double,
        isWarmupSet: Bool = false,
        rpe: Int? = nil,
        notes: String? = nil,
        order: Int = 0,
        isDone: Bool = false
    ) {
        self.id = UUID()
        self.reps = reps
        self.weight = weight
        self.isWarmupSet = isWarmupSet
        self.rpe = rpe
        self.notes = notes
        self.order = order
        self.isDone = isDone
    }
    
    // Hashable conformance
    static func == (lhs: ExerciseSet, rhs: ExerciseSet) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
