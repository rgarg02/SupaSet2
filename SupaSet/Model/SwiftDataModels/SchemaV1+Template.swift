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
    final class Template: Identifiable {
        var id: UUID
        var name: String
        var notes: String
        @Relationship(deleteRule: .cascade) var exercises: [TemplateExercise]
        var createdAt: Date
        var lastUsed: Date?
        
        init(name: String, notes: String = "", exercises: [TemplateExercise] = []) {
            self.id = UUID()
            self.name = name
            self.notes = notes
            self.exercises = exercises
            self.createdAt = Date()
        }
    }
    @Model
    final class TemplateExercise: Identifiable {
        var id: UUID
        var exerciseID: String
        var order: Int
        var targetSets: Int
        var targetReps: Int
        var notes: String?
        
        init(exerciseID: String, order: Int = 0, targetSets: Int, targetReps: Int, notes: String? = nil) {
            self.id = UUID()
            self.exerciseID = exerciseID
            self.order = order
            self.targetSets = targetSets
            self.targetReps = targetReps
            self.notes = notes
        }
    }
}
