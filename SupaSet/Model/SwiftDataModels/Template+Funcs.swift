//
//  Template+Funcs.swift
//  SupaSet
//
//  Created by Rishi Garg on 1/21/25.
//

extension Template{
    func insertExercise(_ exerciseID: String) {
        let templateExercise = TemplateExercise(exerciseID: exerciseID, order: exercises.count)
        exercises.append(templateExercise)
    }
}
extension Template: Equatable {
    public static func == (lhs: Template, rhs: Template) -> Bool {
        lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.notes == rhs.notes &&
        lhs.createdAt == rhs.createdAt &&
        lhs.lastUsed == rhs.lastUsed &&
        lhs.order == rhs.order &&
        lhs.exercises == rhs.exercises
    }
}

extension TemplateExercise: Equatable {
    public static func == (lhs: TemplateExercise, rhs: TemplateExercise) -> Bool {
        lhs.id == rhs.id &&
        lhs.exerciseID == rhs.exerciseID &&
        lhs.notes == rhs.notes &&
        lhs.order == rhs.order &&
        lhs.sets == rhs.sets
    }
}

extension TemplateExerciseSet: Equatable {
    public static func == (lhs: TemplateExerciseSet, rhs: TemplateExerciseSet) -> Bool {
        lhs.id == rhs.id &&
        lhs.order == rhs.order &&
        lhs.reps == rhs.reps &&
        lhs.weight == rhs.weight
    }
}
