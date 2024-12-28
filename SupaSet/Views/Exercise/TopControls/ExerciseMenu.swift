//
//  ExerciseMenu.swift
//  SupaSet
//
//  Created by Rishi Garg on 12/17/24.
//

import SwiftUI
import SwiftData
struct ExerciseMenu: View {
    let workoutExercise: WorkoutExercise
    @State private var changeExercise: Bool = false
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        MenuButtons(exerciseID: workoutExercise.exerciseID, changeExercise: $changeExercise)
        .padding()
        .fullScreenCover(isPresented: $changeExercise) {
            NavigationView{
                ExerciseListPickerView(workoutExercise: workoutExercise)
                    .toolbar{
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                changeExercise = false
                            }
                            .foregroundColor(.theme.accent)
                        }
                    }
            }
        }
    }
}
#Preview {
    let preview = PreviewContainer.preview
    NavigationView {
        ExerciseMenu(workoutExercise: preview.workout.sortedExercises[0])
            .modelContainer(preview.container)
            .environment(preview.viewModel)
    }
}
