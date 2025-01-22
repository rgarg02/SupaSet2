//
//  SchemaV1+Routine.swift
//  SupaSet
//
//  Created by Rishi Garg on 1/21/25.
//

import SwiftData
import Foundation

extension SupaSetSchemaV1 {
    @Model
    final class Template: Hashable {
        var id: UUID
        var name: String = "New Template"
        var notes: String = ""
        var order: Int
        @Relationship(deleteRule: .cascade) var exercises: [TemplateExercise]
        var createdAt: Date
        var lastUsed: Date?
        
        init(name: String = "New Template", notes: String = "", exercises: [TemplateExercise] = [], order: Int) {
            self.id = UUID()
            self.name = name
            self.notes = notes
            self.exercises = exercises
            self.createdAt = Date()
            self.order = order
        }
        var sortedExercises: [TemplateExercise] {
            exercises.sorted { $0.order < $1.order }
        }
        func updateOrder(_ newOrder: Int) {
                self.order = newOrder
            }
    }
    @Model
    final class TemplateExercise: Hashable {
        var id: UUID
        var exerciseID: String
        var order: Int
        var sets: [TemplateExerciseSet]
        var notes: String?
        
        init(exerciseID: String, order: Int, sets: [TemplateExerciseSet] = [TemplateExerciseSet(order: 0)], notes: String? = nil) {
            self.id = UUID()
            self.exerciseID = exerciseID
            self.order = order
            self.sets = sets
            self.notes = notes
        }
        var sortedSets: [TemplateExerciseSet] {
            sets.sorted { $0.order < $1.order }
        }
        func insertSet(reps: Int) {
            let newSet = TemplateExerciseSet(
                reps: reps,
                order: sets.count
            )
            sets.append(newSet)
            reorderSets()
        }
        func reorderSets() {
            let sortedSets = sets.sorted { $0.order < $1.order }
            for (index, set) in sortedSets.enumerated() {
                set.order = index
            }
        }
        func deleteSet(_ set: TemplateExerciseSet) {
            sets.removeAll(where: { $0.id == set.id })
            reorderSets()
        }
    }
    
    @Model
    final class TemplateExerciseSet: Hashable {
        var id: UUID
        var reps: Int
        var weight: Double
        var order: Int
        init(reps: Int = 1, order: Int, weight: Double = 0) {
            self.id = UUID()
            self.reps = reps
            self.order = order
            self.weight = weight
        }
    }
    
}
