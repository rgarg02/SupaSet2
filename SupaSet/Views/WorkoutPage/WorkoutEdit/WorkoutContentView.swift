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
    @State private var moving: Bool = false
    var body: some View {
        VStack {
            WorkoutScrollContent(
                workout: workout,
                scrolledExercise: $scrolledExercise,
                focused: focused,
                moving: $moving
            )
        }
        .toolbar(content: {
            ToolbarItem(placement: .principal) {
                VStack{
                    DragIndicator()
                        .opacity(1 - progress)
                    WorkoutTopControls(
                        workout: workout,
                        isExpanded: $isExpanded
                    )
                }
                .background(Color.theme.background)
            }
        })
        .opacity(1 - progress)
        if !moving {
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

#Preview {
    let preview = PreviewContainer.preview
    NavigationView{
        WorkoutContentView(
            workout: preview.workout,
            isExpanded: .constant(false),
            scrolledExercise: .constant(nil),
            focused: FocusState<Bool>().projectedValue,
            progress: 0.0,
            showExercisePicker: .constant(false)
        )
    }
    .modelContainer(preview.container)
}
