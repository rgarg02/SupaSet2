//
//  File.swift
//  SupaSet
//
//  Created by Rishi Garg on 1/29/25.
//


// MARK: - Workout Extensions
extension SupaSetSchemaV1.Workout {
    var currentExercise: SupaSetSchemaV1.WorkoutExercise? {
        exercises.first { $0.order == currentExerciseOrder }
    }
    
    var currentSet: SupaSetSchemaV1.ExerciseSet? {
        currentExercise?.sets.first { $0.order == currentSetOrder }
    }
    
    var sortedExercises: [SupaSetSchemaV1.WorkoutExercise] {
        exercises.sorted { $0.order < $1.order }
    }
    
    func updateCurrentOrder() {

        if exercises.isEmpty {
            currentExerciseOrder = 0
            currentSetOrder = 0
            return
        }
        
        currentExerciseOrder = min(currentExerciseOrder, exercises.map(\.order).max() ?? 0)
        
        if let currentExercise = currentExercise {
            currentSetOrder = min(currentSetOrder, currentExercise.sets.map(\.order).max() ?? 0)
        } else {
            currentSetOrder = 0
        }
    }
    
    func completeCurrentSet() {
        guard let currentSet = currentSet else { return }
        
        currentSet.isDone = true
        
        if let nextSet = nextIncompleteSet() {
            currentExerciseOrder = nextSet.exerciseOrder
            currentSetOrder = nextSet.setOrder
        }
        
        updateCurrentOrder()
    }
    
    private func nextIncompleteSet() -> (exerciseOrder: Int, setOrder: Int)? {
        let sortedExercises = exercises.sorted { $0.order < $1.order }
        
        // Check current exercise
        if let currentExercise = currentExercise {
            let sortedSets = currentExercise.sets.sorted { $0.order < $1.order }
            if let nextSet = sortedSets.first(where: { $0.order > currentSetOrder && !$0.isDone }) {
                return (currentExerciseOrder, nextSet.order)
            }
        }
        
        // Check subsequent exercises
        for exercise in sortedExercises where exercise.order > currentExerciseOrder {
            if let firstIncompleteSet = exercise.sets.sorted(by: { $0.order < $1.order })
                .first(where: { !$0.isDone }) {
                return (exercise.order, firstIncompleteSet.order)
            }
        }
        
        return nil
    }
}
