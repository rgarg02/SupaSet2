//
//  WorkoutContentView.swift
//  SupaSet
//
//  Created by Rishi Garg on 11/21/24.
//

import SwiftUI


struct WorkoutContentView: View {
    @Bindable var workout: Workout
    @Binding var isExpanded: Bool
    var scrollOffset: CGFloat
    @Binding var scrolledExercise: Int?
    var focused: FocusState<Bool>.Binding
    var progress: CGFloat
    @Binding var showExercisePicker: Bool
    @State private var reorderExercise: Bool = false
    var body: some View {
        VStack {
            DragIndicator()
                .opacity(1 - progress)
            
            WorkoutTopControls(
                workout: workout,
                isExpanded: $isExpanded,
                scrollOffset: scrollOffset
            )
            
            WorkoutScrollContent(
                workout: workout,
                scrolledExercise: $scrolledExercise,
                reorderExercises: $reorderExercise,
                focused: focused,
                scrollOffset: scrollOffset
            )
        }
        .opacity(1 - progress)
        if !reorderExercise {
            AddExerciseButton(showExercisePicker: $showExercisePicker)
                .opacity(1 - progress)
                .padding(.horizontal, 50.0)
                .padding(.vertical)
        }
    }
}
struct AddExerciseButton: View {
    @Binding var showExercisePicker: Bool
    
    var body: some View {
        CustomButton(
            icon: "plus.circle",
            title: "Add Exercises",
            style: .filled(),
            action: {
                withAnimation {
                    showExercisePicker = true
                }
            }
        )
    }
}
