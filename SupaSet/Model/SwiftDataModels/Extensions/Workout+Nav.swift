//
//  Workout+Nav.swift
//  SupaSet
//
//  Created by Rishi Garg on 1/29/25.
//

// MARK: - Workout Navigation
extension SupaSetSchemaV1.Workout {
    func moveToNextSet() {
        currentSetOrder += 1
        updateCurrentOrder()
    }
    
    func moveToPreviousSet() {
        currentSetOrder = max(0, currentSetOrder - 1)
        updateCurrentOrder()
    }
    
    func moveToNextExercise() {
        if currentExerciseOrder < exercises.count - 1 {
            currentExerciseOrder += 1
            currentSetOrder = 0
            updateCurrentOrder()
        }
    }
    
    func moveToPreviousExercise() {
        if currentExerciseOrder > 0 {
            currentExerciseOrder -= 1
            currentSetOrder = 0
            updateCurrentOrder()
        }
    }
}
