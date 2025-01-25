//
//  Tempalte+Copy.swift
//  SupaSet
//
//  Created by Rishi Garg on 1/23/25.
//

import Foundation

extension Template {
    func copy() -> Template {
        let template = Template(order: order)
        template.createdAt = self.createdAt
        template.exercises = self.exercises.map { $0.copy() }
        template.lastUsed = self.lastUsed
        template.name = self.name
        template.notes = self.notes
        return template
        }
}
extension TemplateExercise {
    func copy() -> TemplateExercise {
        let exercise = TemplateExercise(exerciseID: exerciseID, order: order, notes: notes)
        exercise.sets = sets.map { $0.copy() }
        return exercise
    }
}
extension TemplateExerciseSet {
    func copy() -> TemplateExerciseSet {
        let set = TemplateExerciseSet(order: order)
        set.reps = reps
        set.weight = weight
        return set
    }
}
