//
//  Schema.swift
//  SupaSet
//
//  Created by Rishi Garg on 11/13/24.
//

import SwiftData

enum SupaSetSchemaV1: VersionedSchema {
    static var models: [any PersistentModel.Type] {
        [Workout.self, WorkoutExercise.self, ExerciseSet.self, ExerciseDetail.self]
    }
    static var versionIdentifier: Schema.Version = .init(1, 0, 0)
}

