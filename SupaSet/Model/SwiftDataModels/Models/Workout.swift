//
//  Workout.swift
//  SupaSet
//
//  Created by Rishi Garg on 1/29/25.
//
import Foundation
import SwiftData

// MARK: - Models
extension SupaSetSchemaV1 {
    @Model
    final class Workout: Hashable, Identifiable {
        private(set) var id: UUID
        var name: String
        var date: Date
        var endTime: Date?
        var isFinished: Bool
        var notes: String
        var currentExerciseOrder: Int
        var currentSetOrder: Int
        
        @Relationship(deleteRule: .cascade)
        var exercises: [WorkoutExercise] = []
        
        var duration: TimeInterval {
            guard let endTime = endTime else {
                return Date().timeIntervalSince(date)
            }
            return endTime.timeIntervalSince(date)
        }
        
        var totalVolume: Double {
            exercises.reduce(0) { $0 + $1.totalVolume }
        }
        
        init(name: String,
             date: Date = Date(),
             endTime: Date? = nil,
             isFinished: Bool = false,
             notes: String = "",
             currentExerciseOrder: Int = 0,
             currentSetOrder: Int = 0) {
            self.id = UUID()
            self.name = name
            self.date = date
            self.endTime = endTime
            self.isFinished = isFinished
            self.notes = notes
            self.currentExerciseOrder = currentExerciseOrder
            self.currentSetOrder = currentSetOrder
        }
        
        init(template: Template) {
            self.id = UUID()
            self.name = template.name
            self.date = Date()
            self.isFinished = false
            self.currentExerciseOrder = 0
            self.currentSetOrder = 0
            self.notes = ""
            
            self.exercises = template.exercises.map { templateExercise in
                let workoutExercise = WorkoutExercise(
                    exerciseID: templateExercise.exerciseID,
                    order: templateExercise.order,
                    notes: templateExercise.notes
                )
                workoutExercise.sets = templateExercise.sets.map {
                    ExerciseSet(
                        reps: $0.reps,
                        weight: $0.weight,
                        order: $0.order
                    )
                }
                return workoutExercise
            }
        }
    }
}
extension Workout {
    var progress: Double {
        guard !sortedExercises.isEmpty else { return 0 }
        let completedExercises = sortedExercises.filter { $0.isCompleted }.count
        return Double(completedExercises) / Double(sortedExercises.count)
    }
    var timeLapsed: TimeInterval {
        return Date().timeIntervalSince(date)
    }
}
