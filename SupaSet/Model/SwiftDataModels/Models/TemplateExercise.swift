//
//  TemplateExercise.swift
//  SupaSet
//
//  Created by Rishi Garg on 1/29/25.
//


import SwiftData
import Foundation

extension SupaSetSchemaV1 {
    
    @Model
    final class TemplateExercise: Hashable {
        var id: UUID
        var exerciseID: String
        var order: Int
        @Relationship(deleteRule: .cascade) var sets: [TemplateExerciseSet]
        @Relationship(inverse: \Template.exercises) var template: Template?
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
}
