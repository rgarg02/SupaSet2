//
//  File.swift
//  SupaSet
//
//  Created by Rishi Garg on 1/29/25.
//


// MARK: - Workout Extensions
extension SupaSetSchemaV1.Workout {
    // Helper to find the first incomplete exercise and its first incomplete set
    var firstIncompleteExerciseAndSet: (exercise: WorkoutExercise, set: ExerciseSet)? {
        // Iterate through sorted exercises
        for exercise in self.exercises.sorted(by: { $0.order < $1.order }) {
            // Find the first set within this exercise that is not done
            if let firstIncompleteSet = exercise.sets.sorted(by: { $0.order < $1.order }).first(where: { !$0.isDone }) {
                // Found the first incomplete set in the workout
                return (exercise, firstIncompleteSet)
            }
        }
        // If no incomplete set is found in any exercise
        return nil
    }
        
    // Dynamically computes the current exercise based on the first incomplete set
    var currentExerciseComputed: WorkoutExercise? {
        if let firstIncomplete = firstIncompleteExerciseAndSet {
            return firstIncomplete.exercise
        }
        // Fallback: If all sets/exercises are done, return the last exercise,
        // or the first if the workout just started/is empty.
        return exercises.sorted { $0.order < $1.order }.last ?? exercises.first
    }
    
    // Dynamically computes the current set based on the first incomplete set
    var currentSetComputed: ExerciseSet? {
        if let firstIncomplete = firstIncompleteExerciseAndSet {
            return firstIncomplete.set
        }
        // Fallback: If all sets are done, return the last set of the computed current exercise.
        return currentExerciseComputed?.sets.sorted { $0.order < $1.order }.last
    }
    
    var sortedExercises: [SupaSetSchemaV1.WorkoutExercise] {
        exercises.sorted { $0.order < $1.order }
    }
}
