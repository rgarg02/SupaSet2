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
    var endTime: Date?
    var isFinished: Bool
    var notes: String?
    var duration: TimeInterval?
    var totalVolume: Double?  // Total weight lifted across all exercises
    @Relationship(deleteRule: .cascade) var exercises: [WorkoutExercise] = []
    
    // New properties for tracking current position
    var currentExerciseOrder: Int
    var currentSetOrder: Int
    
    init(
        name: String,
        date: Date = Date(),
        endTime: Date? = nil,
        isFinished: Bool = false,
        notes: String? = nil,
        duration: TimeInterval? = nil,
        currentExerciseOrder: Int = 0,
        currentSetOrder: Int = 0
    ) {
        self.id = UUID()
        self.name = name
        self.date = date
        self.endTime = endTime
        self.isFinished = isFinished
        self.notes = notes
        self.duration = duration
        self.currentExerciseOrder = currentExerciseOrder
        self.currentSetOrder = currentSetOrder
    }
    
    // MARK: - Computed Properties
    var currentExercise: WorkoutExercise? {
        exercises.first { $0.order == currentExerciseOrder }
    }
    
    var currentSet: ExerciseSet? {
        currentExercise?.sets.first { $0.order == currentSetOrder }
    }
    
    func calculateTotalVolume() -> Double {
        exercises.reduce(0) { total, exercise in
            total + exercise.sets.reduce(0) { setTotal, set in
                setTotal + (set.weight * Double(set.reps))
            }
        }
    }
    
    // MARK: - Navigation Methods
    func completeCurrentSet() {
        guard let currentExercise = currentExercise,
              currentSetOrder < currentExercise.sets.count else { return }
        
        // Mark current set as done
        let existingSet = currentExercise.sets[currentSetOrder]
        existingSet.isDone = true
        
        // Find next incomplete set
        if let nextSet = nextIncompleteSet() {
            currentExerciseOrder = nextSet.exerciseOrder
            currentSetOrder = nextSet.setOrder
        }
        
        // Always validate the order after changes
        updateCurrentOrder()
    }
    
    private func nextIncompleteSet() -> (exerciseOrder: Int, setOrder: Int)? {
        // Get sorted exercises to ensure proper order
        let sortedExercises = exercises.sorted { $0.order < $1.order }
        
        // First check remaining sets in current exercise
        if let currentExercise = currentExercise {
            let sortedSets = currentExercise.sets.sorted { $0.order < $1.order }
            if let nextSet = sortedSets.first(where: { $0.order > currentSetOrder && !$0.isDone }) {
                return (currentExerciseOrder, nextSet.order)
            }
        }
        
        // Then check subsequent exercises
        for exercise in sortedExercises where exercise.order > currentExerciseOrder {
            let sortedSets = exercise.sets.sorted { $0.order < $1.order }
            if let firstIncompleteSet = sortedSets.first(where: { !$0.isDone }) {
                return (exercise.order, firstIncompleteSet.order)
            }
        }
        
        return nil
    }
    
    // MARK: - Order Validation
    func updateCurrentOrder() {
        if exercises.isEmpty {
            currentExerciseOrder = 0
            currentSetOrder = 0
            return
        }
        
        // Validate exercise order
        let maxExerciseOrder = exercises.map(\.order).max() ?? 0
        currentExerciseOrder = min(currentExerciseOrder, maxExerciseOrder)
        print("current exercise order \(currentExerciseOrder)")
        // Validate set order
        if let currentExercise = currentExercise {
            let maxSetOrder = currentExercise.sets.map(\.order).max() ?? 0
            currentSetOrder = min(currentSetOrder, maxSetOrder)
            print("current set order \(currentSetOrder)")
        } else {
            currentSetOrder = 0
        }
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
        self.sets = [ExerciseSet(reps: 0, weight: 0)]
    }
    
    // Computed property for total volume of this exercise
    var totalVolume: Double {
        sets.reduce(0) { total, set in
            total + (set.weight * Double(set.reps))
        }
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
    
}

// MARK: - Hashable Conformance
extension Workout {
    static func == (lhs: Workout, rhs: Workout) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension WorkoutExercise {
    static func == (lhs: WorkoutExercise, rhs: WorkoutExercise) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension ExerciseSet {
    static func == (lhs: ExerciseSet, rhs: ExerciseSet) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
// MARK: - Required Workout Model Extensions
extension Workout {
    func moveToNextSet() {
        // Implement the logic to move to the next set
        currentSetOrder += 1
    }
    
    func moveToPreviousSet() {
        // Implement the logic to move to the previous set
        currentSetOrder = max(0, currentSetOrder - 1)
    }
    
    // Helper methods for workout progression
    func moveToNextExercise() {
        if currentExerciseOrder < exercises.count - 1 {
            currentExerciseOrder += 1
            currentSetOrder = 0
        }
    }
    
    func moveToPreviousExercise() {
        if currentExerciseOrder > 0 {
            currentExerciseOrder -= 1
            currentSetOrder = 0
        }
    }
}
// First, update the Workout extension with a safer updateCurrentSet method:
extension Workout {
    func updateCurrentSet(_ set: ExerciseSet) {
        guard let currentExercise = currentExercise,
              currentSetOrder < currentExercise.sets.count else { return }
        
        // Instead of direct assignment, update properties
        let existingSet = currentExercise.sets[currentSetOrder]
        existingSet.weight = set.weight
        existingSet.reps = set.reps
        existingSet.isWarmupSet = set.isWarmupSet
        existingSet.rpe = set.rpe
        existingSet.notes = set.notes
        existingSet.isDone = set.isDone
    }
}
extension WorkoutExercise {
    func updateSet(at order: Int, with newValues: ExerciseSet) {
        guard order < sets.count else { return }
        let existingSet = sets[order]
        existingSet.weight = newValues.weight
        existingSet.reps = newValues.reps
        existingSet.isWarmupSet = newValues.isWarmupSet
        existingSet.rpe = newValues.rpe
        existingSet.notes = newValues.notes
        existingSet.isDone = newValues.isDone
    }
}
