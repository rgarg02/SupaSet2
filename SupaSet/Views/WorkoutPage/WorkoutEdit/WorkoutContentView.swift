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
    @Binding var scrolledExercise: Int?
    var focused: FocusState<Bool>.Binding
    var progress: CGFloat
    @Binding var showExercisePicker: Bool
    @State private var dragging: Bool = false
    let minimizing: Bool
    var body: some View {
        VStack {
            DragIndicator()
                .opacity(1 - progress)
            WorkoutTopControls(
                workout: workout,
                isExpanded: $isExpanded
            )
            .opacity(minimizing ? CGFloat(1 - (progress * 10)) : 1)
            WorkoutScrollContent(
                workout: workout,
                scrolledExercise: $scrolledExercise,
                focused: focused,
                dragging: $dragging,
                minimizing: minimizing
            )
            .opacity(minimizing ? CGFloat(1 - (progress * 10)) : 1)
        }
        if !dragging {
            AddExerciseButton(showExercisePicker: $showExercisePicker)
                .opacity(1 - progress)
                .padding(.horizontal, 50.0)
                .padding(.vertical)
                .opacity(minimizing ? CGFloat(1 - (progress * 10)) : 1)
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

#Preview {
    let preview = PreviewContainer.preview
    NavigationView{
        WorkoutContentView(
            workout: preview.workout,
            isExpanded: .constant(false),
            scrolledExercise: .constant(nil),
            focused: FocusState<Bool>().projectedValue,
            progress: 0.0,
            showExercisePicker: .constant(false), minimizing: false
        )
    }
    .modelContainer(preview.container)
}
