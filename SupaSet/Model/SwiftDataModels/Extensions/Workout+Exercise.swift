//
//  Execise+Manage.swift
//  SupaSet
//
//  Created by Rishi Garg on 1/29/25.
//

import Foundation


// MARK: - Exercise Management
extension SupaSetSchemaV1.Workout {
    
    func insertExercise(_ exerciseID: String) {
        let workoutExercise = SupaSetSchemaV1.WorkoutExercise(
            exerciseID: exerciseID,
            order: exercises.count
        )
        exercises.append(workoutExercise)
    }
    
    func getWorkoutExercise(for exerciseID: String) -> SupaSetSchemaV1.WorkoutExercise? {
        exercises.first { $0.exerciseID == exerciseID }
    }
    
    func containsExercise(_ exerciseID: String) -> Bool {
        exercises.contains { $0.exerciseID == exerciseID }
    }
}
