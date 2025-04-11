//
//  WorkoutExercise.swift
//  SupaSet
//
//  Created by Rishi Garg on 1/29/25.
//
import SwiftData
import Foundation

extension SupaSetSchemaV1 {
    @Model
    final class WorkoutExercise: Hashable, Identifiable {
        
        #Index<WorkoutExercise>([\.exerciseID, \.order])
        private(set) var id: UUID
        var exerciseID: String
        var order: Int
        var notes: String?
        @Relationship(deleteRule: .cascade)
        var sets: [ExerciseSet] = []
        
        @Relationship(inverse: \Workout.exercises)
        var workout: Workout?
        
        var totalVolume: Double {
            sets.reduce(0) { $0 + ($1.weight * Double($1.reps)) }
        }
        
        init(exerciseID: String, order: Int = 0, notes: String? = nil) {
            self.id = UUID()
            self.exerciseID = exerciseID
            self.order = order
            self.notes = notes
            self.sets = [ExerciseSet(reps: 0, weight: 0)]
        }
        init(id: UUID, exerciseID: String, order: Int = 0, notes: String? = nil) {
            self.id = id
            self.exerciseID = exerciseID
            self.order = order
            self.notes = notes
            self.sets = [ExerciseSet(reps: 0, weight: 0)]
        }
    }
}
