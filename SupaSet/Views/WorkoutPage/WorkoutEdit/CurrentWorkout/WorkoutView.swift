//
//  WorkoutView.swift
//  SupaSet
//
//  Created by Rishi Garg on 3/30/25.
//


import SwiftUI
import SwiftData

struct WorkoutView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Binding var show: Bool
    @Bindable var workout: SupaSetSchemaV1.Workout
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 20) {
                HStack {
                    DateLabel(date: workout.date.formatted(date: .abbreviated, time: .shortened))
                    Spacer()
                    WorkoutTimer(workout: workout)
                }
                NotesSection(item: workout)
                
                // Exercises and sets
                ForEach(sortedExercises) { exercise in
                    ExerciseView(workoutExercise: exercise)
                }
                
                CancelFinishAddView(item: workout, originalItem: workout, show: $show, isNew: true)
            }
            .padding()
        }
        .background(.thickMaterial)
        .scrollIndicators(.hidden)
    }
    
    private var sortedExercises: [SupaSetSchemaV1.WorkoutExercise] {
        workout.exercises.sorted(by: { $0.order < $1.order })
    }
}

// Exercise view component
struct ExerciseView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var workoutExercise: SupaSetSchemaV1.WorkoutExercise
    @Environment(ExerciseViewModel.self) private var viewModel
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Exercise header
            ExerciseTopControls(exercise: workoutExercise, dragging: false)
            // Set header
            VStack(spacing: 4) {
                // Column headers
                SetColumnNamesView(exerciseID: workoutExercise.exerciseID, isTemplate: false)
                
                // Sets list
                ForEach(sortedSets) { set in
                    @Bindable var set = set
                    let order = workoutExercise.sets.lazy
                        .filter { $0.type == .working && $0.order < set.order }
                        .count
                    SwipeAction(cornerRadius: 8, direction: .trailing) {
                        SetRowViewCombined(order: order, isTemplate: false, weight: $set.weight, reps: $set.reps, isDone: $set.isDone, type: $set.type, exerciseID: workoutExercise.exerciseID)
                            
                    } actions: {
                        Action(tint: .red, icon: "trash.fill") {
                            withAnimation(.easeInOut) {
                                // Update orders of following sets before deleting
                                let setOrder = set.order
                                let setsToUpdate = workoutExercise.sets.filter { $0.order > setOrder }
                                
                                for setToUpdate in setsToUpdate {
                                    setToUpdate.order -= 1
                                }
                                workoutExercise.deleteSet(set)
                                modelContext.delete(set)
                            }
                        }
                    }
                }
                // Add set button
                PlaceholderSetRowView(templateSet: false) {
                    Task{
                        DispatchQueue.main.async {
                            withAnimation(.default) {
                                let lastSet = sortedSets.last
                                workoutExercise.insertSet(reps: lastSet?.reps ?? 0, weight: lastSet?.weight ?? 0)
                            }
                        }
                    }
                }
            }
            .padding(.vertical)
        }
    }
    private var sortedSets: [SupaSetSchemaV1.ExerciseSet] {
        workoutExercise.sets.sorted(by: { $0.order < $1.order })
    }
}


