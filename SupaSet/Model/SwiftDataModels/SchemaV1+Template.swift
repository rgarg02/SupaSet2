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
        var sets: [TemplateExerciseSets]
        var notes: String?
        
        init(exerciseID: String, order: Int = 0, sets: [TemplateExerciseSets] = [TemplateExerciseSets(order: 0)], notes: String? = nil) {
            self.id = UUID()
            self.exerciseID = exerciseID
            self.order = order
            self.sets = sets
            self.notes = notes
        }
        var sortedSets: [TemplateExerciseSets] {
            sets.sorted { $0.order < $1.order }
        }
    }
    
    @Model
    final class TemplateExerciseSets: Hashable {
        var id: UUID
        var reps: Int
        var order: Int
        init(reps: Int = 1, order: Int) {
            self.id = UUID()
            self.reps = reps
            self.order = order
        }
    }
    
}
