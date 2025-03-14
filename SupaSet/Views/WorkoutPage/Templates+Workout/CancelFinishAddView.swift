//
//  CancelFinishAddView.swift
//  SupaSet
//
//  Created by Rishi Garg on 1/22/25.
//

import SwiftUI

struct CancelFinishAddView<T: Nameable>: View {
    @Bindable var item: T
    var originalItem: T?
    @Binding var show: Bool
    let isNew: Bool
    var onSave: (() -> Void)?  // Optional closure for custom save behavior
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.alertController) private var alertController
    var body: some View {
        VStack {
            NavigationLink {
                Group {
                    if let workout = item as? Workout {
                        ExerciseListPickerView(workout: workout)
                    } else if let template = item as? Template {
                        ExerciseListPickerView(template: template)
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                        .font(.title3)
                        .foregroundColor(.theme.background)
                    
                    Text("Add Exercises")
                        .font(.headline)
                        .foregroundColor(.theme.background)
                }
                .modifier(LongButtonModifier())
            }
            CancelFinishButtons
        }
    }
    private var CancelFinishButtons: some View {
        // Cancel/Delete and Finish/Save Buttons
        HStack {
            let buttonTitle = isNew ? "Cancel" : "Delete"
            let itemType = item is Workout ? "Workout" : "Template"
            let title = "\(buttonTitle) \(itemType)"
            
            CustomButton(
                icon: "trash",
                title: title,
                style: .filled(
                    background: .red,
                    foreground: .theme.textOpposite
                ),
                action: {
                    let buttons: [AlertButton] = [
                        AlertButton(title: "Go Back", role: .cancel),
                        AlertButton(title: buttonTitle, role: .destructive, action: {
                            delete()
                        })
                    ]
                    alertController.present(
                        .confirmationDialog,
                        title: "\(title)?",
                        buttons: buttons
                    )
                }
            )
            
            CustomButton(
                icon: "checkmark",
                title: "\(isNew ? "Finish" : "Save") \(itemType)",
                style: .filled(
                    background: .theme.secondary,
                    foreground: .theme.textOpposite
                ),
                action: {
                    finish()
                }
            )
        }
    }
    private func finish() {
        if let workout = item as? Workout {
            finishWorkout(workout)
        } else if let template = item as? Template {
            finishTemplate(template)
        }
    }
    
    private func finishWorkout(_ workout: Workout) {
        WorkoutActivityManager.shared.endAllActivities()
        
        show = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            if !workout.isFinished {
                workout.isFinished = true
                workout.endTime = Date()
            }
            do {
                try modelContext.save()
            } catch {
                alertController.present(
                    title: "Error Saving Workout",
                    message: "There was an error saving the workout. Please try again."
                )
            }
        }
    }
    
    private func finishTemplate(_ template: Template) {
        if let customSave = onSave {
            // Use custom save behavior if provided
            customSave()
        } else {
            // Default save behavior
            do {
                if isNew {
                    template.createdAt = Date()
                    modelContext.insert(template)
                }
                try modelContext.save()
                withAnimation {
                    dismiss()
                }
            } catch {
                alertController.present(
                    title: isNew ? "Error Saving Template" : "Error Updating Template",
                    message: "There was an error \(isNew ? "saving" : "updating") the template. Please try again."
                )
            }
        }
    }
    
    private func delete() {
        if isNew {
            if let workout = item as? Workout {
                deleteWorkout(workout)
            } else if let template = item as? Template {
                deleteTemplate(template)
            }
        } else {
            if let originalItem {
                if let workout = originalItem as? Workout {
                    deleteWorkout(workout)
                } else if let template = originalItem as? Template {
                    deleteTemplate(template)
                } else {
                    fatalError("Item type not supported")
                }
            } else {
                dismiss()
            }
        }
    }
    private func deleteWorkout(_ workout: Workout) {
        show = false
        // add 0.25 sec delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            withAnimation(.smooth) {
                modelContext.delete(workout)
                WorkoutActivityManager.shared.endAllActivities()
            }
        }
    }
    
    private func deleteTemplate(_ template: Template) {
        modelContext.delete(template)
        withAnimation(.easeInOut(duration: 0.25)) {
            dismiss()
        }
    }
}

