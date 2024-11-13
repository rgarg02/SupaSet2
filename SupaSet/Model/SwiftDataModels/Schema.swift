//
//  Schema.swift
//  SupaSet
//
//  Created by Rishi Garg on 11/13/24.
//

import SwiftData
typealias Workout = SupaSetSchema.Workout
typealias WorkoutExercise = SupaSetSchema.WorkoutExercise
typealias ExerciseSet = SupaSetSchema.ExerciseSet
enum SupaSetSchema: VersionedSchema {
    static var models: [any PersistentModel.Type] {
        [Workout.self, WorkoutExercise.self, ExerciseSet.self]
    }
    
    static var versionIdentifier: Schema.Version = .init(1, 0, 0)
    
}

