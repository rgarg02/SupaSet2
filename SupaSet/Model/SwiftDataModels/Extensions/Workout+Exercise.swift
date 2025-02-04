//
//  Execise+Manage.swift
//  SupaSet
//
//  Created by Rishi Garg on 1/29/25.
//

import Foundation


// MARK: - Exercise Management
extension SupaSetSchemaV1.Workout {
    func reorderExercises() {
        let sortedExercises = exercises.sorted { $0.order < $1.order }
        for (index, exercise) in sortedExercises.enumerated() {
            exercise.order = index
        }
    }
    
    func moveExercise(from source: IndexSet, to destination: Int) {
        var exerciseArray = sortedExercises
        exerciseArray.move(fromOffsets: source, toOffset: destination)
        
        for (index, exercise) in exerciseArray.enumerated() {
            if let existingExercise = exercises.first(where: { $0.id == exercise.id }) {
                existingExercise.order = index
            }
        }
    }
    
    func insertExercise(_ exerciseID: String) {
        let workoutExercise = SupaSetSchemaV1.WorkoutExercise(
            exerciseID: exerciseID,
            order: exercises.count
        )
        exercises.append(workoutExercise)
        reorderExercises()
        updateCurrentOrder()
    }
    
    func getWorkoutExercise(for exerciseID: String) -> SupaSetSchemaV1.WorkoutExercise? {
        exercises.first { $0.exerciseID == exerciseID }
    }
    
    func containsExercise(_ exerciseID: String) -> Bool {
        exercises.contains { $0.exerciseID == exerciseID }
    }
}
