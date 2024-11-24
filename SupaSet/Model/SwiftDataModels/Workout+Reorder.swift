//
//  WorkoutModel+Reorder.swift
//  SupaSet
//
//  Created by Rishi Garg on 11/7/24.
//

import Foundation

extension Workout {
    /// Reorders all exercises in the workout to ensure consecutive ordering.
    ///
    /// This method sorts exercises by their current order and reassigns order values
    /// to ensure they are sequential (0, 1, 2, ...). This helps maintain data consistency
    /// after deletions or other operations that might create gaps in the ordering.
    func reorderExercises() {
        let sortedExercises = exercises.sorted { $0.order < $1.order }
        for (index, exercise) in sortedExercises.enumerated() {
            exercise.order = index
        }
    }
    
    /// Moves an exercise from one position to another, updating the order values of affected exercises.
    ///
    /// This method only updates the `order` properties of affected exercises without modifying
    /// the array structure itself.
    ///
    /// - Parameters:
    ///   - source: The current index of the exercise to move
    ///   - destination: The desired index for the exercise
    ///
    /// - Note: If either index is out of bounds or if source equals destination, the method will return without making changes

    
    /// Moves an exercise using SwiftUI's IndexSet format to a new position.
    ///
    /// This is a convenience wrapper for `moveExercise(from:to:)` that accepts SwiftUI's
    /// native IndexSet format, making it compatible with SwiftUI's `.onMove` modifier.
    ///
    /// - Parameters:
    ///   - source: The IndexSet containing the source index
    ///   - destination: The desired destination index
    func moveExercise(from source: IndexSet, to destination: Int) {
        // Convert exercises to array for easier manipulation
        var exerciseArray = sortedExercises
        // Perform the move operation on the array
        exerciseArray.move(fromOffsets: source, toOffset: destination)
        // Update the order of all exercises to reflect new positions
        for (index, exercise) in exerciseArray.enumerated() {
            // Find the exercise in the set and update its order
            if let existingExercise = exercises.first(where: { $0.id == exercise.id }) {
                existingExercise.order = index
            }
        }
    }
    
    /// Inserts a new exercise at a specific position in the workout.
    ///
    /// This method creates a new WorkoutExercise instance and inserts it at the specified position,
    /// then reorders all exercises to maintain proper sequential ordering.
    ///
    /// - Parameters:
    ///   - exercise: The Exercise to add to the workout
    ///   - position: The desired position for the new exercise
    func insertExercise(_ exercise: Exercise) {
        let workoutExercise = WorkoutExercise(exercise: exercise, order: exercises.count)
        exercises.append(workoutExercise)
        reorderExercises()
        updateCurrentOrder()
    }
    
    /// Deletes an exercise from the workout and reorders remaining exercises.
    ///
    /// This method removes the specified exercise and updates the order of remaining exercises
    /// to maintain sequential ordering without gaps.
    ///
    /// - Parameter exercise: The Exercise to remove from the workout
    func deleteExercise(exercise: Exercise) {
        exercises.removeAll(where: { $0.exercise.id == exercise.id })
        reorderExercises()
        updateCurrentOrder()
    }
    func deleteExercise(at indexSet: IndexSet){
        let exerciseArray = sortedExercises
        if let exercise = exerciseArray.first(where: { $0.order == indexSet.first! }) {
            deleteExercise(exercise: exercise.exercise)
            reorderExercises()
            updateCurrentOrder()
        }
        
    }
}

// MARK: - Sorting Extensions
extension Workout {
    /// Returns an array of workout exercises sorted by their order property.
    ///
    /// This computed property provides convenient access to exercises in their proper order,
    /// which is essential for display and manipulation purposes.
    ///
    /// - Returns: An array of WorkoutExercise instances sorted by their order property
    var sortedExercises: [WorkoutExercise] {
        exercises.sorted { $0.order < $1.order }
    }
}
// MARK: - Query Extensions
extension Workout {
    /// Returns the WorkoutExercise instance for a given Exercise if it exists in the workout.
    /// - Parameter exercise: The Exercise to look for
    /// - Returns: The corresponding WorkoutExercise if found, nil otherwise
    func getWorkoutExercise(for exercise: Exercise) -> WorkoutExercise? {
        exercises.first { $0.exercise.id == exercise.id }
    }
    
    /// Checks if a given exercise is already in the workout
    /// - Parameter exercise: The Exercise to check
    /// - Returns: True if the exercise is in the workout, false otherwise
    func containsExercise(_ exercise: Exercise) -> Bool {
        exercises.contains { $0.exercise.id == exercise.id }
    }
}
