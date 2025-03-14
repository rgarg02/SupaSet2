//
//  ScrollContent+Funcs.swift
//  SupaSet
//
//  Created by Rishi Garg on 12/10/24.
//

import SwiftUI
extension ScrollContentView {    
    func checkAndSwapItems(at location: CGPoint) {
        // Implementation for handling exercises swapping
        guard let selectedExercise = dragState.selectedExercise as? WorkoutExercise,
              let draggedIndex = sortedExercises.firstIndex(where: { $0.id == selectedExercise.id }) else { return }
        
        // Find potential target to swap with
        for (index, exercise) in sortedExercises.enumerated() {
            if index != draggedIndex,
               let frame = dragState.itemFrames[exercise.id],
               frame.contains(location) {
                // Swap orders
                let tempOrder = exercise.order
                withAnimation(.bouncy(duration: 0.25)) {
                    exercise.order = selectedExercise.order
                    selectedExercise.order = tempOrder
                }
                // Trigger haptic feedback
                dragState.hapticFeedback.toggle()
                break
            }
        }
    }
}
