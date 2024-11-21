//
//  WorkoutNameEditor.swift
//  SupaSet
//
//  Created by Rishi Garg on 11/21/24.
//

import SwiftUI
// MARK: - WorkoutNameEditor
struct WorkoutNameEditor: View {
    @Bindable var workout: Workout
    @Binding var isEditingName: Bool
    @FocusState var isFocused: Bool
    
    var body: some View {
        TextField("Workout Name", text: $workout.name)
            .font(.title2.bold())
            .multilineTextAlignment(.center)
            .focused($isFocused)
            .onAppear {
                isFocused = true
                selectAllTextOnAppear()
            }
            .onSubmit {
                finishEditing()
            }
    }
    
    private func selectAllTextOnAppear() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            UIApplication.shared.sendAction(#selector(UIResponder.selectAll(_:)),
                                         to: nil,
                                         from: nil,
                                         for: nil)
        }
    }
    
    private func finishEditing() {
        withAnimation {
            isEditingName = false
            WorkoutActivityManager.shared.updateWorkoutActivity(workout: workout)
        }
    }
}
