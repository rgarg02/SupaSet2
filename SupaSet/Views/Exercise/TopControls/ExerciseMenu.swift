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
    @Binding var showExercisePicker: Bool
    @State private var deleteExercise: Bool = false
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(ExerciseViewModel.self) private var viewModel
    @Environment(\.alertController) private var alertController
    var body: some View {
        MenuButtons(exerciseID: exercise.exerciseID, changeExercise: $showExercisePicker, deleteExercise: $deleteExercise)
            .padding()
            .onChange(of: deleteExercise) { oldValue, newValue in
                if newValue {
                    let buttons = [
                        AlertButton(title: "Delete", role: .destructive, action: {
                            delete()
                        }),
                        AlertButton(title: "Cancel", role: .cancel, action: {
                            deleteExercise = false
                        })
                    ]
                    alertController.present(.alert, title: "Delete Exercise?", message: "Confirm delete \(viewModel.getExerciseName(for: exercise.exerciseID))", buttons: buttons)
                    dismiss()
                }
            }
    }
    func delete() {
        switch exercise {
        case let workoutExercise as WorkoutExercise:
            if let workout = workoutExercise.workout {
                modelContext.delete(workoutExercise)
                withAnimation(.bouncy(duration: 0.3)) {
                    workout.reorderExercises()
                }
                
            }
        case let templateExercise as TemplateExercise:
            if let template = templateExercise.template {
                modelContext.delete(templateExercise)
                withAnimation(.bouncy(duration: 0.3)) {
                    template.reorderExercises()
                }
            }
        default:
            alertController.present(.alert, title: "Something Went Wrong", message: "Unable to delete exercise")
        }
        deleteExercise = false
    }
}
#Preview {
    let preview = PreviewContainer.preview
    NavigationView {
        ExerciseMenu(exercise: preview.workout.sortedExercises[0], showExercisePicker: .constant(false))
            .modelContainer(preview.container)
            .environment(preview.viewModel)
    }
}
