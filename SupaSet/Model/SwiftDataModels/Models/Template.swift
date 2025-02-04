//
//  Template.swift
//  SupaSet
//
//  Created by Rishi Garg on 1/29/25.
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
        func reorderExercises() {
            let sortedExercises = exercises.sorted { $0.order < $1.order }
            for (index, exercise) in sortedExercises.enumerated() {
                exercise.order = index
            }
        }
    }
}
