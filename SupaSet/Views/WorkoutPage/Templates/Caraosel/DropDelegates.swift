//
//  DropDelegates.swift
//  SupaSet
//
//  Created by Rishi Garg on 1/25/25.
//

import SwiftUI

struct DropOutsideDelegate: DropDelegate {
    @Binding var current: Template?
    @Binding var collapsed: Bool
    func performDrop(info: DropInfo) -> Bool {
        current = nil
        collapsed = false
        return true
    }
    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }
}
struct DragRelocateDelegate: DropDelegate {
    let item: Template
    @Binding var current: Template?
    @Binding var collapsed: Bool
    func dropEntered(info: DropInfo) {
        // Safely unwrap the template we're dragging:
        guard let dragging = current, dragging != item else { return }
        collapsed = true
        let tempOrder = item.order
        withAnimation(.bouncy) {
            item.order = dragging.order
            dragging.order = tempOrder
        }
        
    }
    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }
    func performDrop(info: DropInfo) -> Bool {
        current = nil
        collapsed = false
        return true
    }
}
import SwiftUI
import SwiftData
import UniformTypeIdentifiers

// Drag and drop delegate for workout exercises
struct DragRelocateDelegateExercise: DropDelegate {
    let item: WorkoutExercise
    @Binding var current: WorkoutExercise?
    @Binding var collapsed: Bool
    @Environment(\.modelContext) private var modelContext
    
    func dropEntered(info: DropInfo) {
        if current == nil { return }
        
        guard let dragging = current, dragging != item else { return }
        collapsed = true
        let tempOrder = item.order
        withAnimation(.bouncy) {
            item.order = dragging.order
            dragging.order = tempOrder
        }
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
    
    func performDrop(info: DropInfo) -> Bool {
        // Animation is complete, reset the collapsed state
        collapsed = false
        
        // Clear the current dragging exercise
        self.current = nil
        return true
    }
}

// Delegate for handling drops outside of any specific exercise
struct DropOutsideDelegateExercise: DropDelegate {
    @Binding var current: WorkoutExercise?
    @Binding var collapsed: Bool
    
    func dropEntered(info: DropInfo) {
        // Keep the view collapsed while dragging
        collapsed = true
    }
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
    func performDrop(info: DropInfo) -> Bool {
        // Animation is complete, reset the collapsed state
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            collapsed = false
        }
        
        // Clear the current dragging exercise
        current = nil
        return true
    }
}

// Extension for WorkoutExercise to update order
extension WorkoutExercise {
    // Update all exercises after deleting one
    static func updateOrderAfterDeletion(in workout: Workout, deletedOrder: Int) {
        for exercise in workout.exercises where exercise.order > deletedOrder {
            exercise.order -= 1
        }
    }
    
    // Move an exercise to the end
    func moveToEnd() {
        if let workout = self.workout {
            let maxOrder = workout.exercises.map { $0.order }.max() ?? -1
            self.order = maxOrder + 1
        }
    }
}
