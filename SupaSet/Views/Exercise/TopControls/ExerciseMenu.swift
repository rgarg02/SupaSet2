//
//  ExerciseMenu.swift
//  SupaSet
//
//  Created by Rishi Garg on 12/17/24.
//

import SwiftUI
import SwiftData
struct ExerciseMenu<T: ExerciseMenuType>: View {
    let exercise: T
    @State private var changeExercise: Bool = false
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        MenuButtons(exerciseID: exercise.exerciseID, changeExercise: $changeExercise)
        .padding()
        .fullScreenCover(isPresented: $changeExercise) {
            NavigationView{
                Group {
                    if let workoutExercise = exercise as? WorkoutExercise {
                        ExerciseListPickerView(workoutExercise: workoutExercise)
                    } else if let templateExercise = exercise as? TemplateExercise {
                        ExerciseListPickerView(templateExercise: templateExercise)
                    }
                }
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
        ExerciseMenu(exercise: preview.workout.sortedExercises[0])
            .modelContainer(preview.container)
            .environment(preview.viewModel)
    }
}
