//
//  CancelFinishAddView.swift
//  SupaSet
//
//  Created by Rishi Garg on 1/22/25.
//

import SwiftUI

struct CancelFinishAddView<T: Nameable>: View {
    @Bindable var item: T
    @Binding var show: Bool
    let isNew: Bool
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    @Environment(\.alertController) var alertController
    var body: some View {
        // Cancel, Finish, Add buttons
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
                        .font(.title3) // Matches medium size's icon font
                        .foregroundColor(.theme.background) // Foreground color
                    
                    Text("Add Exercises")
                        .font(.headline)
                        .foregroundColor(.theme.background) // Foreground color
                }
                .modifier(LongButtonModifier())
            }
            HStack{
                let buttonTitle = "\(isNew ? "Cancle": "Delete")"
                let title = "\(buttonTitle) \(item as? Workout != nil ? "Workout" : "Template")"
                CustomButton(
                    icon: "trash",
                    title: title,
                    style: .filled(
                        background: .red,
                        foreground: .theme.textOpposite
                    ),
                    action: {
                        let buttons: [AlertButton] = [AlertButton(title: "Go Back", role: .cancel),
                                                      AlertButton(title: buttonTitle, role: .destructive, action: {
                            delete()
                        })]
                        alertController.present(.confirmationDialog, title: "\(title)?", buttons: buttons)
                    }
                )
                CustomButton(
                    icon: "checkmark",
                    title: "\(isNew ? "Finish" : "Save") \(item as? Workout != nil ? "Workout" : "Template")",
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
        
    }
    func finish() {
        if let workout = item as? Workout {
            if !workout.isFinished {
                workout.isFinished = true
                workout.endTime = Date()
            }
            do {
                try modelContext.save()
                withAnimation {
                    show = false
                }
                WorkoutActivityManager.shared.endAllActivities()
            } catch {
                alertController.present(title: "Error Saving Workout", message: "There was an error saving the workout. Please try again.")
            }
        } else if let template = item as? Template {
            if isNew {
                template.createdAt = Date()
                do {
                    modelContext.insert(template)
                    try modelContext.save()
                    withAnimation {
                        dismiss()
                    }
                } catch {
                    alertController.present(title: "Error Saving Template", message: "There was an error saving the template. Please try again.")
                }
            } else {
                do {
                    try modelContext.save()
                    withAnimation {
                        dismiss()
                    }
                } catch {
                    alertController.present(title: "Error Updating Template", message: "There was an error updating the template. Please try again.")
                }
            }
        }
    }
    
    func delete() {
        if let workout = item as? Workout {
            modelContext.delete(workout)
            WorkoutActivityManager.shared.endAllActivities()
            withAnimation {
                show = false
            }
        } else if let template = item as? Template {
            modelContext.delete(template)
            withAnimation {
                dismiss()
            }
        }
    }
}

#Preview("Cancel Finish Add View") {
    let sampleWorkout = Workout(name: "Morning Workout")
    CancelFinishAddView(item: sampleWorkout, show: .constant(true), isNew: true)
        .padding()
}
