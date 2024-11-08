//
//  WorkoutExercise+Reorder.swift
//  SupaSet
//
//  Created by Rishi Garg on 11/7/24.
//

//
//  WorkoutModel+Sets.swift
//  SupaSet
//
//  Created by Rishi Garg on 11/7/24.
//

import Foundation
import SwiftData

// MARK: - WorkoutExercise Set Management
extension WorkoutExercise {
    /// Reorders all sets to ensure sequential ordering.
    ///
    /// This method sorts sets by their current order and reassigns order values
    /// to ensure they are sequential (0, 1, 2, ...).
    func reorderSets() {
        let sortedSets = sets.sorted { $0.order < $1.order }
        for (index, set) in sortedSets.enumerated() {
            set.order = index
        }
    }
    
    /// Moves a set from one position to another.
    ///
    /// - Parameters:
    ///   - source: The current index of the set
    ///   - destination: The desired index for the set
    func moveSet(from source: Int, to destination: Int) {
        guard source != destination,
              source >= 0, source < sets.count,
              destination >= 0, destination <= sets.count else { return }
        
        let setToMove = sortedSets[source]
        
        if source < destination {
            // Moving down
            for index in (source + 1)...destination {
                sortedSets[index].order -= 1
            }
        } else {
            // Moving up
            for index in destination..<source {
                sortedSets[index].order += 1
            }
        }
        
        setToMove.order = destination
    }
    
    /// Moves sets using SwiftUI's IndexSet format.
    ///
    /// - Parameters:
    ///   - source: The IndexSet containing the source index
    ///   - destination: The desired destination index
    func moveSet(from source: IndexSet, to destination: Int) {
        guard let sourceIndex = source.first else { return }
        moveSet(from: sourceIndex, to: destination)
    }
    
    /// Adds a new set to the exercise.
    ///
    /// - Parameters:
    ///   - reps: Number of repetitions for the set
    ///   - weight: Weight used for the set
    ///   - isWarmup: Whether this is a warmup set
    ///   - rpe: Rate of Perceived Exertion (optional)
    ///   - notes: Additional notes for the set (optional)
    func insertSet(reps: Int,
                weight: Double,
                isWarmup: Bool = false,
                rpe: Int? = nil,
                notes: String? = nil) {
        let newSet = ExerciseSet(
            reps: reps,
            weight: weight,
            isWarmupSet: isWarmup,
            rpe: rpe,
            notes: notes,
            order: sets.count,
            isDone: false
        )
        sets.append(newSet)
        reorderSets()
    }
    
    /// Deletes a set from the exercise.
    ///
    /// - Parameter set: The set to delete
    func deleteSet(_ set: ExerciseSet) {
        sets.removeAll(where: { $0.id == set.id })
        reorderSets()
    }

    
}

// MARK: - Helper Properties
extension WorkoutExercise {
    /// Returns the number of completed sets.
    var completedSetsCount: Int {
        sets.filter { $0.isDone }.count
    }
    
    /// Returns the total number of sets.
    var totalSetsCount: Int {
        sets.count
    }
    
    /// Checks if all sets are completed.
    var isCompleted: Bool {
        !sets.isEmpty && sets.allSatisfy { $0.isDone }
    }
    
    /// Returns only the warmup sets.
    var warmupSets: [ExerciseSet] {
        sortedSets.filter { $0.isWarmupSet }
    }
    
    /// Returns only the working sets (non-warmup).
    var workingSets: [ExerciseSet] {
        sortedSets.filter { !$0.isWarmupSet }
    }
}

// MARK: - SortingExercuse Extensions
extension WorkoutExercise {
    /// Returns an array of exercise sets sorted by their order property.
    ///
    /// This computed property provides convenient access to sets in their proper order,
    /// which is essential for display and manipulation purposes.
    ///
    /// - Returns: An array of ExerciseSet instances sorted by their order property
    var sortedSets: [ExerciseSet] {
        sets.sorted { $0.order < $1.order }
    }
}
