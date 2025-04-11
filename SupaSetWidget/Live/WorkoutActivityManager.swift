//
//  WorkoutActivityManager.swift
//  SupaSet
//
//  Created by Rishi Garg on 11/11/24.
//  UPDATED to use computed properties for LA state
//

import ActivityKit
import Foundation
import SwiftData

class WorkoutActivityManager {
    static let shared = WorkoutActivityManager()
    private var currentActivity: Activity<WorkoutAttributes>?
    private var exerciseViewModel: ExerciseViewModel?
    private var modelContext: ModelContext?
    private var currentContentState: WorkoutAttributes.ContentState?

    // Default initializer
    private init() { }

    // Set the model context and initialize ExerciseViewModel
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        // Ensure ExerciseViewModel is initialized (needed for getExerciseName)
        if self.exerciseViewModel == nil {
             self.exerciseViewModel = ExerciseViewModel(modelContext: context)
        }
    }

    // Helper to access ExerciseViewModel safely
    func getExerciseViewModel() -> ExerciseViewModel? {
        // Ensure context is set before returning view model
        guard modelContext != nil else {
            print("Warning: ModelContext not set in WorkoutActivityManager.")
            return nil
        }
        // Initialize if needed (e.g., if context was set after initial init)
        if self.exerciseViewModel == nil, let ctx = self.modelContext {
             self.exerciseViewModel = ExerciseViewModel(modelContext: ctx)
        }
        return self.exerciseViewModel
    }


    // Central state update function
    func updateLiveActivity(updates: (inout WorkoutAttributes.ContentState) -> Void) {
        guard currentActivity != nil, var updatedState = currentContentState else {
            print("Cannot update: No active activity or current state.")
            return
        }
        updates(&updatedState) // Apply specific changes
        currentContentState = updatedState // Store the updated state

        Task {
            await currentActivity?.update(.init(state: updatedState, staleDate: nil))
            print("Live Activity Updated state: \(updatedState)")
        }
    }

    // START: Uses computed properties for initial state
    func startWorkoutActivity(workout: Workout) throws {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("Live Activities are not enabled.")
            return
        }
        guard let exerciseViewModel = getExerciseViewModel() else { // Use getter
            print("Exercise view model not initialized, cannot start workout activity")
            return
        }
        guard currentActivity == nil else {
            return
        }
        endAllActivities() // Ensure clean start

        // *** Use COMPUTED properties to get the initial state ***
        let currentExercise = workout.currentExerciseComputed
        let currentSet = workout.currentSetComputed
        // *** ***

        let attributes = WorkoutAttributes(
            workoutId: workout.id.uuidString,
            startTime: workout.date
        )

        // Build state based on computed properties' details
        let exerciseOrder = currentExercise?.order ?? 0
        let setOrder = currentSet?.order ?? 0

        let initialState = WorkoutAttributes.ContentState(
            workoutName: workout.name,
            // Use computed properties to get details
            currentExerciseName: currentExercise.map { exerciseViewModel.getExerciseName(for: $0.exerciseID) } ?? "Workout Complete",
            currentSetNumber: setOrder + 1, // Get order from computed set (+1 for display)
            totalSets: currentExercise?.sets.count ?? 0,
            weight: currentSet?.weight ?? 0,
            targetReps: currentSet?.reps ?? 0,
            type: currentSet?.type ?? .working,
            exerciseNumber: exerciseOrder + 1, // Get order from computed exercise (+1 for display)
            totalExercises: workout.exercises.count
        )

        do {
            let activity = try Activity.request(
                attributes: attributes,
                content: .init(state: initialState, staleDate: nil),
                pushType: nil
            )
            currentActivity = activity
            currentContentState = initialState // Store the initial state
            print("Live Activity Started with computed state: \(initialState)")

        } catch {
            print("Error starting Live Activity: \(error.localizedDescription)")
            currentContentState = nil
            throw error
        }
    }

    // NEW: Function to refresh the entire LA state based on workout's computed properties
    func refreshLiveActivityState(workout: Workout) {
         guard currentActivity != nil, let exerciseViewModel = getExerciseViewModel() else {
             print("Cannot refresh state: No activity or view model.")
             return
         }

         // *** Use COMPUTED properties ***
         let currentExercise = workout.currentExerciseComputed
         let currentSet = workout.currentSetComputed
         // *** ***

         // Fetch necessary display details from computed properties
         let exerciseOrder = currentExercise?.order ?? 0
         let setOrder = currentSet?.order ?? 0
         let currentExName = currentExercise.map { exerciseViewModel.getExerciseName(for: $0.exerciseID) } ?? "Workout Complete"

         // Use the central update function
         updateLiveActivity { state in
             state.workoutName = workout.name
             state.currentExerciseName = currentExName
             state.currentSetNumber = setOrder + 1
             state.totalSets = currentExercise?.sets.count ?? 0
             state.weight = currentSet?.weight ?? 0
             state.targetReps = currentSet?.reps ?? 0
             state.type = currentSet?.type ?? .working
             state.exerciseNumber = exerciseOrder + 1
             state.totalExercises = workout.exercises.count
         }
          print("Refreshed Live Activity State from computed properties.")
    }


    // Specific update functions (useful for single value changes)
    func updateLiveActivityWeight(_ newWeight: Double) {
        updateLiveActivity { state in
            state.weight = newWeight
        }
    }

    func updateLiveActivityReps(_ newReps: Int) {
        updateLiveActivity { state in
            state.targetReps = newReps
        }
    }
    // Add other specific wrappers like updateLiveActivitySetType if needed


    // END: Modified to clear the stored state
    func endWorkoutActivity() {
        guard let activity = currentActivity else { return }
        Task {
            // Use the last known state or fetch fresh if needed for final display
             let finalState = currentContentState ?? activity.content.state // Example: use stored
            await activity.end(.init(state: finalState, staleDate: nil), dismissalPolicy: .immediate)
            currentActivity = nil
            currentContentState = nil // Clear the stored state
            print("Live Activity Ended")
        }
    }

    // END ALL: Modified to clear the stored state
    func endAllActivities() {
        Task {
            // Fetch all activities of this type managed by the system
            for activity in Activity<WorkoutAttributes>.activities {
                await activity.end(nil, dismissalPolicy: .immediate)
            }
            // Clear manager's tracking if it was tracking one of these
            if currentActivity != nil && Activity<WorkoutAttributes>.activities.contains(where: { $0.id == currentActivity!.id }) == false {
                 currentActivity = nil
                 currentContentState = nil
            } else if currentActivity != nil {
                 // It might still exist if the loop finished before the async end completed fully
                 // Double-check if needed, or just clear manager state
                 currentActivity = nil
                 currentContentState = nil
            }
            print("All Live Activities Ended")
        }
    }


    // MARK: - Refactored Set Management Actions (Examples)
    // These functions should be called AFTER the SwiftData model has been updated by the caller (e.g., View/ViewModel)

    // Call this after marking a set as done in SwiftData
    func triggerSetCompletionUpdate(workout: Workout) {
        refreshLiveActivityState(workout: workout)
    }

    // Call this after changing weight in SwiftData for the CURRENT computed set
    func triggerWeightUpdate(newWeight: Double) {
        // Check if the weight actually belongs to the set the LA is currently showing
        // (Optional, but good practice if updates can come from non-current sets)
        // guard let currentSet = currentContentState, newWeight == workout.currentSetComputed?.weight else { return }
        updateLiveActivityWeight(newWeight)
    }

    // Call this after changing reps in SwiftData for the CURRENT computed set
    func triggerRepsUpdate(newReps: Int) {
        updateLiveActivityReps(newReps)
    }

    // Call this after navigating (e.g., manually changing currentExerciseOrder/currentSetOrder)
    func triggerNavigationUpdate(workout: Workout) {
        refreshLiveActivityState(workout: workout)
    }

    // --- OR ---
    // If you prefer the manager handles the SwiftData interaction too (requires modelContext):

    func completeSetAndRefresh(_ workout: Workout) {
        guard (modelContext != nil) else { return } // Need context
         // This function now specifically uses the COMPUTED current set
         guard let currentSetToComplete = workout.currentSetComputed else {
              print("No current set found to complete in manager.")
              return
         }
         currentSetToComplete.isDone = true // Update model
         // Save context if needed
         // try? context.save()
         refreshLiveActivityState(workout: workout) // Refresh LA
    }

    func incrementWeightAndRefresh(_ workout: Workout, by amount: Double = 2.5) {
        guard (modelContext != nil) else { return } // Need context
         // Operate on the COMPUTED current set
         guard let currentSetToModify = workout.currentSetComputed else { return }

         let newWeight = max(0, currentSetToModify.weight + amount)
         currentSetToModify.weight = newWeight // Update model
         // try? context.save()

         // Update the LA specifically for weight
         updateLiveActivityWeight(newWeight)
    }
    func decrementWeightAndRefresh(_ workout: Workout, by amount: Double = 2.5) {
        guard (modelContext != nil) else { return } // Need context
         // Operate on the COMPUTED current set
         guard let currentSetToModify = workout.currentSetComputed else { return }

         let newWeight = max(0, currentSetToModify.weight - amount)
         currentSetToModify.weight = newWeight // Update model
         // try? context.save()

         // Update the LA specifically for weight
         updateLiveActivityWeight(newWeight)
    }
    func incrementRepsAndRefresh(_ workout: Workout, by amount: Int = 1) {
        guard (modelContext != nil) else { return } // Need context
         // Operate on the COMPUTED current set
         guard let currentSetToModify = workout.currentSetComputed else { return }

        let newReps = max(0, currentSetToModify.reps + amount)
        currentSetToModify.reps = newReps // Update model
         // try? context.save()

         // Update the LA specifically for weight
         updateLiveActivityReps(newReps)
    }
    func decrementRepsAndRefresh(_ workout: Workout, by amount: Int = 1) {
        guard (modelContext != nil) else { return } // Need context
         // Operate on the COMPUTED current set
         guard let currentSetToModify = workout.currentSetComputed else { return }

        let newReps = max(0, currentSetToModify.reps - amount)
        currentSetToModify.reps = newReps // Update model
         // try? context.save()

         // Update the LA specifically for weight
         updateLiveActivityReps(newReps)
    }

}
