//
//  DragRelocateDelegate.swift
//  SupaSet
//
//  Created by Rishi Garg on 11/23/24.
//

import UniformTypeIdentifiers
import SwiftUI
import SwiftData

// First, create this custom Transferable type outside your view
struct ExerciseTransfer: Transferable, Codable {
    let id: UUID
    
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .exerciseTransfer)
    }
}

extension UTType {
    static let exerciseTransfer = UTType(exportedAs: "com.SupaSet.persistentModelID")
}
struct DropExerciseDelegate: DropDelegate {
    @Binding var moving: Bool
    @Binding var dragging: WorkoutExercise?
    let exercise: WorkoutExercise
    let workout: Workout
    @Binding var haptics: Bool
    func dropUpdated(info: DropInfo) -> DropProposal? {
       return DropProposal(operation: .move)
    }
    func performDrop(info: DropInfo) -> Bool {
        withAnimation(.snappy(duration: 0.3)) {
            moving = false
            dragging = nil
        }
        return true
    }
    
    func dropEntered(info: DropInfo) {
        if let draggingExercise = dragging,
           draggingExercise != exercise,
           let from = workout.sortedExercises.firstIndex(of: draggingExercise),
           let to = workout.sortedExercises.firstIndex(of: exercise) {
            withAnimation(.snappy(duration: 0.4)) {
                workout.moveExercise(from: IndexSet(integer: from),
                                   to: to > from ? to + 1 : to)
            }
            haptics.toggle()
        }
    }
    
}
struct DropOutsideDelegate: DropDelegate {
    @Binding var dragging: WorkoutExercise?
    @Binding var moving: Bool
        
    func dropEntered(info: DropInfo) {
        moving = true
    }
    func performDrop(info: DropInfo) -> Bool {
        withAnimation(.snappy(duration: 0.3)) {
            moving = false
            dragging = nil
        }
        return false
    }
    func dropUpdated(info: DropInfo) -> DropProposal? {
       return DropProposal(operation: .move)
    }
}
