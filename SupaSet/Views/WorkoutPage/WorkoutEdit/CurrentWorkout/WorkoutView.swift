// ExerciseView.swift UPDATED

import SwiftUI
import SwiftData

// WorkoutView remains mostly the same, displaying the data
struct WorkoutView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Binding var show: Bool
    @Bindable var workout: SupaSetSchemaV1.Workout
    @Environment(ExerciseViewModel.self) private var viewModel // Ensure viewModel is injected

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 20) {
                HStack {
                    DateLabel(date: workout.date.formatted(date: .abbreviated, time: .shortened))
                    Spacer()
                    WorkoutTimer(workout: workout)
                }
                NotesSection(item: workout)

                // Pass the ExerciseViewModel down if ExerciseView needs it directly
                ForEach(sortedExercises) { exercise in
                    ExerciseView(workoutExercise: exercise)
                        .environment(viewModel) // Pass viewModel if needed
                }

                CancelFinishAddView(item: workout, originalItem: workout, show: $show, isNew: true)
                    .padding(.bottom)
            }
            .padding()
        }
        .background(.thickMaterial)
        .scrollIndicators(.hidden)
         // Add an onChange here if workout-level properties affect the LA
         .onChange(of: workout.name) { _, newName in
             WorkoutActivityManager.shared.triggerNavigationUpdate(workout: workout)
         }
    }

    private var sortedExercises: [SupaSetSchemaV1.WorkoutExercise] {
        workout.exercises.sorted(by: { $0.order < $1.order })
    }
}

// Exercise view component - UPDATED
struct ExerciseView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var workoutExercise: SupaSetSchemaV1.WorkoutExercise
    @Environment(ExerciseViewModel.self) private var viewModel // Assume viewModel is available

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
                    @Bindable var set = set // Make set bindable for direct modification
                    let order = workoutExercise.sets.lazy
                        .filter { $0.type == .working && $0.order < set.order }
                        .count
                    SwipeAction(cornerRadius: 8, direction: .trailing) {
                        SetRowViewCombined(order: order, isTemplate: false, weight: $set.weight, reps: $set.reps, isDone: $set.isDone, type: $set.type, exerciseID: workoutExercise.exerciseID)
                            // --- Weight Change ---
                            .onChange(of: set.weight) { _, newWeight in
                                Task(priority: .background){
                                    // Check if this set IS the dynamically current set
                                    if let workout = workoutExercise.workout,
                                       workout.currentSetComputed?.id == set.id {
                                        // Use specific manager update
                                        WorkoutActivityManager.shared.updateLiveActivityWeight(newWeight)
                                    }
                                }
                            }
                            // --- Reps Change ---
                            .onChange(of: set.reps) { _, newReps in
                                Task(priority: .background){
                                    // Check if this set IS the dynamically current set
                                    if let workout = workoutExercise.workout,
                                       workout.currentSetComputed?.id == set.id {
                                        // Use specific manager update
                                        WorkoutActivityManager.shared.updateLiveActivityReps(newReps)
                                    }
                                }
                            }
                            // --- Completion Change ---
                            .onChange(of: set.isDone) { _, isNowDone in
                                if isNowDone {
                                    Task(priority: .background) { // Keep background task
                                        guard let workout = workoutExercise.workout else {
                                            print("Error: Workout object not found for set completion.")
                                            return
                                        }
                                        WorkoutActivityManager.shared.refreshLiveActivityState(workout: workout)
                                        // --- ---
                                        print("Set completion detected and Live Activity refreshed.") // Debugging
                                    }
                                }
                            }

                    } actions: {
                        // --- Delete Action ---
                        Action(tint: .red, icon: "trash.fill") {
                            withAnimation(.easeInOut) {
                                guard let workout = workoutExercise.workout else { return }

                                // 1. Delete from context
                                modelContext.delete(set)

                                // 2. Remove from array and reorder remaining (via helper)
                                workoutExercise.deleteSet(set)

                                // 4. Refresh Live Activity entirely after deletion
                                WorkoutActivityManager.shared.refreshLiveActivityState(workout: workout)
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
                                // Ensure insertSet adds to SwiftData context if not automatic
                                workoutExercise.insertSet(reps: lastSet?.reps ?? 0, weight: lastSet?.weight ?? 0)
                                // Potentially refresh LA if adding a set should update totals immediately
                                if let workout = workoutExercise.workout {
                                     WorkoutActivityManager.shared.refreshLiveActivityState(workout: workout)
                                }
                            }
                        }
                    }
                }
            }
            .padding(.vertical)
            // --- Other Exercise-Level Changes ---
            .onChange(of: workoutExercise.exerciseID) { _, _ in
                Task(priority: .background){
                    if let workout = workoutExercise.workout {
                        WorkoutActivityManager.shared.refreshLiveActivityState(workout: workout)
                    }
                }
            }
            .onChange(of: workoutExercise.order) { _, _ in
                Task(priority: .background){
                     if let workout = workoutExercise.workout {
                         WorkoutActivityManager.shared.refreshLiveActivityState(workout: workout)
                     }
                 }
            }
            .onChange(of: workoutExercise.sets.count) { _, _ in
                Task(priority: .background){
                     if let workout = workoutExercise.workout {
                         WorkoutActivityManager.shared.refreshLiveActivityState(workout: workout)
                     }
                 }
            }
        }
    }

    private var sortedSets: [SupaSetSchemaV1.ExerciseSet] {
        workoutExercise.sets.sorted(by: { $0.order < $1.order })
    }
}
