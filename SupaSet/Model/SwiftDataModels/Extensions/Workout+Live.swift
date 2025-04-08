//
//  Workout+Live.swift
//  SupaSet
//
//  Created by Rishi Garg on 1/29/25.
//

// First, update the Workout extension with a safer updateCurrentSet method:
extension Workout {
    func updateCurrentSet(_ set: ExerciseSet) {
        guard let currentExercise = currentExercise,
              let existingSet = currentSet,
              currentSetOrder < currentExercise.sets.count else { return }
        
        // Instead of direct assignment, update properties
        
        existingSet.weight = set.weight
        existingSet.reps = set.reps
        existingSet.type = set.type
        existingSet.rpe = set.rpe
        existingSet.notes = set.notes
        existingSet.isDone = set.isDone
    }
}
extension WorkoutExercise {
    func updateSet(at order: Int, with newValues: ExerciseSet) {
        guard let existingSet = sets.first(where: {$0.order == order}),
              order < sets.count else { return }
        existingSet.weight = newValues.weight
        existingSet.reps = newValues.reps
        existingSet.type = newValues.type
        existingSet.rpe = newValues.rpe
        existingSet.notes = newValues.notes
        existingSet.isDone = newValues.isDone
    }
}
