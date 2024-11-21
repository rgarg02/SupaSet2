//
//  WorkoutNameSection.swift
//  SupaSet
//
//  Created by Rishi Garg on 11/21/24.
//
import SwiftUI

// MARK: - WorkoutNameSection
struct WorkoutNameSection: View {
    @Bindable var workout: Workout
    @State private var isEditingName: Bool = false
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack {
            if isEditingName {
                WorkoutNameEditor(
                    workout: workout,
                    isEditingName: $isEditingName,
                    isFocused: _isFocused
                )
            } else {
                Text(workout.name)
                    .font(.title2.bold())
            }
            
            EditButton(isEditing: isEditingName) {
                withAnimation {
                    isEditingName.toggle()
                }
            }
        }
    }
}
