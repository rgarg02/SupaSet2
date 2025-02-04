//
//  ExerciseSet.swift
//  SupaSet
//
//  Created by Rishi Garg on 1/29/25.
//

import SwiftData
import Foundation

extension SupaSetSchemaV1 {
    @Model
    final class ExerciseSet: Hashable {
        private(set) var id: UUID
        var reps: Int
        var weight: Double
        var isWarmupSet: Bool
        var rpe: Int?
        var notes: String?
        var order: Int
        var isDone: Bool
        
        @Relationship(inverse: \WorkoutExercise.sets)
        var workoutExercise: WorkoutExercise?
        
        init(reps: Int,
             weight: Double,
             isWarmupSet: Bool = false,
             rpe: Int? = nil,
             notes: String? = nil,
             order: Int = 0,
             isDone: Bool = false) {
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
}
