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
