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
        #Index<Workout>([\.date]) // Index on date for efficient querying
        private(set) var id: UUID
        var name: String
        var date: Date
        var endTime: Date?
        var isFinished: Bool
        var notes: String
        
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
             notes: String = "") {
            self.id = UUID()
            self.name = name
            self.date = date
            self.endTime = endTime
            self.isFinished = isFinished
            self.notes = notes
            self.exercises = []
        }
        init(
            id: UUID,
            name: String,
            date: Date = Date(),
            endTime: Date? = nil,
            isFinished: Bool = false,
            notes: String = "") {
                self.id = id
                self.name = name
                self.date = date
                self.endTime = endTime
                self.isFinished = isFinished
                self.notes = notes
                self.exercises = []
            }
        init(template: Template) {
            self.id = UUID()
            self.name = template.name
            self.date = Date()
            self.isFinished = false
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
        let totalSets = sortedExercises.reduce(0) { $0 + $1.sets.count }
        let completedSets = sortedExercises.reduce(0) { $0 + $1.sets.count(where: {$0.isDone}) }
        return Double(completedSets) / Double(totalSets)
    }
    var timeLapsed: TimeInterval {
        return Date().timeIntervalSince(date)
    }
}
