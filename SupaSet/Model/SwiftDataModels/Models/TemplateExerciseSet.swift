//
//  TemplateExerciseSet.swift
//  SupaSet
//
//  Created by Rishi Garg on 1/29/25.
//


import SwiftData
import Foundation

extension SupaSetSchemaV1 {
    @Model
    final class TemplateExerciseSet: Hashable {
        var id: UUID
        var type: SetType
        var reps: Int
        var weight: Double
        var order: Int
        @Relationship(inverse: \TemplateExercise.sets) var templateExercise: TemplateExercise?
        init(reps: Int = 1, type: SetType = .working, order: Int, weight: Double = 0) {
            self.id = UUID()
            self.reps = reps
            self.type = type
            self.order = order
            self.weight = weight
        }
    }
    
}
