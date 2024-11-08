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
    func moveExercise(from source: Int, to destination: Int) {
        guard source != destination,
              source >= 0, source < exercises.count,
              destination >= 0, destination <= exercises.count else { return }
        
        let exerciseToMove = sortedExercises[source]  // Use sortedExercises instead of exercises
        
        if source < destination {
            // Moving down - update orders for exercises between source and destination
            for index in (source + 1)...destination {
                sortedExercises[index].order -= 1
            }
        } else {
            // Moving up - update orders for exercises between destination and source
            for index in destination..<source {
                sortedExercises[index].order += 1
            }
        }
        
        exerciseToMove.order = destination
    }
    
    /// Moves an exercise using SwiftUI's IndexSet format to a new position.
    ///
    /// This is a convenience wrapper for `moveExercise(from:to:)` that accepts SwiftUI's
    /// native IndexSet format, making it compatible with SwiftUI's `.onMove` modifier.
    ///
    /// - Parameters:
    ///   - source: The IndexSet containing the source index
    ///   - destination: The desired destination index
    func moveExercise(from source: IndexSet, to destination: Int) {
        guard let sourceIndex = source.first else { return }
        moveExercise(from: sourceIndex, to: destination)
    }
    
    /// Inserts a new exercise at a specific position in the workout.
    ///
    /// This method creates a new WorkoutExercise instance and inserts it at the specified position,
    /// then reorders all exercises to maintain proper sequential ordering.
    ///
    /// - Parameters:
    ///   - exercise: The Exercise to add to the workout
    ///   - position: The desired position for the new exercise
    func insertExercise(_ exercise: Exercise, at position: Int) {
        let workoutExercise = WorkoutExercise(exercise: exercise, order: position)
        exercises.append(workoutExercise)
        reorderExercises()
    }
    
    /// Deletes an exercise from the workout and reorders remaining exercises.
    ///
    /// This method removes the specified exercise and updates the order of remaining exercises
    /// to maintain sequential ordering without gaps.
    ///
    /// - Parameter exercise: The Exercise to remove from the workout
    func deleteExercise(exercise: Exercise) {
        exercises.removeAll(where: { $0.exercise.id == exercise.id })
        let remainingExercises = sortedExercises
        for (index, remainingExercise) in remainingExercises.enumerated() {
            remainingExercise.order = index
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
