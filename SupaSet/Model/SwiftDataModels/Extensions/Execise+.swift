//
//  Execise+.swift
//  SupaSet
//
//  Created by Rishi Garg on 1/29/25.
//

import Foundation


// MARK: - WorkoutExercise Extensions
extension SupaSetSchemaV1.WorkoutExercise {
    var sortedSets: [SupaSetSchemaV1.ExerciseSet] {
        sets.sorted { $0.order < $1.order }
    }
    
    var completedSetsCount: Int {
        sets.filter(\.isDone).count
    }
    
    var totalSetsCount: Int {
        sets.count
    }
    
    var isCompleted: Bool {
        !sets.isEmpty && sets.allSatisfy(\.isDone)
    }
    
    var warmupSets: [SupaSetSchemaV1.ExerciseSet] {
        sortedSets.filter {$0.type == .warmup}
    }
    
    var workingSets: [SupaSetSchemaV1.ExerciseSet] {
        sortedSets.filter {$0.type == .working}
    }
    
    func reorderSets() {
        let sortedSets = sets.sorted { $0.order < $1.order }
        for (index, set) in sortedSets.enumerated() {
            set.order = index
        }
    }
    
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
    
    func moveSet(from source: IndexSet, to destination: Int) {
        guard let sourceIndex = source.first else { return }
        moveSet(from: sourceIndex, to: destination)
    }
    
    func insertSet(
        reps: Int,
        weight: Double,
        type: SetType = .working,
        rpe: Int? = nil,
        notes: String? = nil
    ) {
        let newSet = SupaSetSchemaV1.ExerciseSet(
            reps: reps,
            weight: weight,
            type: type,
            rpe: rpe,
            notes: notes,
            order: sets.count
        )
        sets.append(newSet)
        reorderSets()
    }
    
    func deleteSet(_ set: SupaSetSchemaV1.ExerciseSet) {
        sets.removeAll { $0.id == set.id }
        reorderSets()
    }
}

// MARK: - Hashable Conformance
extension SupaSetSchemaV1.Workout {
    static func == (lhs: SupaSetSchemaV1.Workout, rhs: SupaSetSchemaV1.Workout) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension SupaSetSchemaV1.WorkoutExercise {
    static func == (lhs: SupaSetSchemaV1.WorkoutExercise, rhs: SupaSetSchemaV1.WorkoutExercise) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension SupaSetSchemaV1.ExerciseSet {
    static func == (lhs: SupaSetSchemaV1.ExerciseSet, rhs: SupaSetSchemaV1.ExerciseSet) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Array Safety Extension
private extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
