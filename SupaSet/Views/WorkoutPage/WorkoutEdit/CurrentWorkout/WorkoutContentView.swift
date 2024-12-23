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
    var progress: CGFloat
    @State private var dragging: Bool = false
    let minimizing: Bool
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
                .opacity(1 - progress)
            WorkoutTopControls(
                workout: workout,
                isExpanded: $isExpanded
            )
            .opacity(minimizing ? CGFloat(1 - (progress * 10)) : 1)
            WorkoutScrollContent(
                workout: workout,
                dragging: $dragging,
                minimizing: minimizing
            )
            .opacity(minimizing ? CGFloat(1 - (progress * 10)) : 1)
        }
        if !dragging {
            NavigationLink{
                ExerciseListPickerView(
                    workout: workout
                )
            } label:{
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                        .foregroundColor(.theme.text)
                        .font(.title3)

                    Text("Add Exercises")
                        .foregroundColor(.theme.text)
                        .font(.title3)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .fill(Color.theme.accent)
                )
            }
            .opacity(1 - progress)
            .padding(.horizontal, 50.0)
            .padding(.vertical)
            .opacity(minimizing ? CGFloat(1 - (progress * 10)) : 1)
        }
    }
}

#Preview {
    let preview = PreviewContainer.preview
    NavigationView{
        ZStack(alignment: .bottom){
            WorkoutContentView(
                workout: preview.workout,
                isExpanded: .constant(false),
                progress: 0.0,
                minimizing: false
            )
        }
    }
    .modelContainer(preview.container)
    .environment(preview.viewModel)
}
