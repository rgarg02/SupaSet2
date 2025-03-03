//
//  WorkoutActivityManager.swift
//  SupaSet
//
//  Created by Rishi Garg on 11/11/24.
//

import ActivityKit
import Foundation
import SwiftData

class WorkoutActivityManager {
    static let shared = WorkoutActivityManager()
    private var currentActivity: Activity<WorkoutAttributes>?
    private var exerciseViewModel: ExerciseViewModel?
    private var modelContext: ModelContext?
    
    // Default initializer without any parameters
    private init() {
        // ExerciseViewModel will be set later when setModelContext is called
    }
    
    // Set the model context and initialize ExerciseViewModel
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        self.exerciseViewModel = ExerciseViewModel(modelContext: context)
    }
    
    func startWorkoutActivity(workout: Workout) throws {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        guard let exerciseViewModel = exerciseViewModel else {
            print("Exercise view model not initialized, cannot start workout activity")
            return
        }
        
        // End any existing activities before starting a new one
        endAllActivities()
        
        let currentExercise = workout.currentExercise
        let currentSet = workout.currentSet
        
        let attributes = WorkoutAttributes(
            workoutId: workout.id.uuidString,
            startTime: workout.date
        )
        
        let contentState = WorkoutAttributes.ContentState(
            workoutName: workout.name,
            currentExerciseName: currentExercise.map { exerciseViewModel.getExerciseName(for: $0.exerciseID) } ?? "",
            currentSetNumber: workout.currentSetOrder + 1,
            totalSets: currentExercise?.sets.count ?? 0,
            weight: currentSet?.weight ?? 0,
            targetReps: currentSet?.reps ?? 0,
            isWarmupSet: currentSet?.isWarmupSet ?? false,
            exerciseNumber: workout.currentExerciseOrder + 1,
            totalExercises: workout.exercises.count
        )
        
        do {
            // First, end the current activity if it exists
            if let currentActivity = currentActivity {
                Task {
                    await currentActivity.end(nil, dismissalPolicy: .immediate)
                }
            }
            
            // Request the new activity
            let activity = try Activity.request(
                attributes: attributes,
                content: .init(state: contentState, staleDate: nil),
                pushType: nil
            )
            
            // Update the current activity reference
            currentActivity = activity
            
        } catch {
            throw error
        }
    }
    
    // Update existing activity
    func updateWorkoutActivity(workout: Workout) {
        // Only proceed if we have an active activity and exercise view model
        guard currentActivity != nil, let exerciseViewModel = exerciseViewModel else {
            return
        }
        
        workout.updateCurrentOrder()
        guard let currentExercise = workout.currentExercise,
              let currentSet = workout.currentSet else {
            return
        }
        
        let contentState = WorkoutAttributes.ContentState(
            workoutName: workout.name,
            currentExerciseName: exerciseViewModel.getExerciseName(for: currentExercise.exerciseID),
            currentSetNumber: workout.currentSetOrder + 1,
            totalSets: currentExercise.sets.count,
            weight: currentSet.weight,
            targetReps: currentSet.reps,
            isWarmupSet: currentSet.isWarmupSet,
            exerciseNumber: workout.currentExerciseOrder + 1,
            totalExercises: workout.exercises.count
        )
        
        Task {
            await currentActivity?.update(.init(state: contentState, staleDate: nil))
        }
    }
    
    // End specific activity
    func endWorkoutActivity() {
        guard let activity = currentActivity else {
            return
        }
        
        Task {
            await activity.end(activity.content, dismissalPolicy: .immediate)
            currentActivity = nil
        }
    }
    
    // End all activities (useful for cleanup)
    func endAllActivities() {
        Task {
            // End current tracked activity
            if let activity = currentActivity {
                await activity.end(nil, dismissalPolicy: .immediate)
                currentActivity = nil
            }
            
            // End any other pending activities
            for activity in Activity<WorkoutAttributes>.activities {
                await activity.end(nil, dismissalPolicy: .immediate)
            }
            
        }
    }
    
    // MARK: - Set Management
    // These methods remain the same but now check for active activity
    
    func completeCurrentSet(workout: Workout) {
        guard currentActivity != nil else { return }
        workout.completeCurrentSet()
        updateWorkoutActivity(workout: workout)
    }
    
    func moveToNextSet(workout: Workout) {
        guard currentActivity != nil else { return }
        workout.moveToNextSet()
        updateWorkoutActivity(workout: workout)
    }
    
    func moveToPreviousSet(workout: Workout) {
        guard currentActivity != nil else { return }
        guard workout.currentSetOrder > 0 else { return }
        
        workout.moveToPreviousSet()
        updateWorkoutActivity(workout: workout)
    }
    
    func incrementWeight(workout: Workout, by amount: Double = 5.0) {
        guard currentActivity != nil,
              let currentSet = workout.currentSet else { return }
        
        let updatedSet = ExerciseSet(
            reps: currentSet.reps,
            weight: currentSet.weight + amount,
            isWarmupSet: currentSet.isWarmupSet,
            rpe: currentSet.rpe,
            notes: currentSet.notes,
            order: currentSet.order,
            isDone: currentSet.isDone
        )
        
        workout.updateCurrentSet(updatedSet)
        updateWorkoutActivity(workout: workout)
    }
    
    func decrementWeight(workout: Workout, by amount: Double = 5.0) {
        guard currentActivity != nil else { return }
        workout.updateCurrentOrder()
        guard let currentSet = workout.currentSet else { return }
        
        let updatedSet = ExerciseSet(
            reps: currentSet.reps,
            weight: max(0, currentSet.weight - amount),
            isWarmupSet: currentSet.isWarmupSet,
            rpe: currentSet.rpe,
            notes: currentSet.notes,
            order: currentSet.order,
            isDone: currentSet.isDone
        )
        
        workout.updateCurrentSet(updatedSet)
        updateWorkoutActivity(workout: workout)
    }
    
    func incrementReps(workout: Workout) {
        guard currentActivity != nil else { return }
        workout.updateCurrentOrder()
        guard let currentSet = workout.currentSet else { return }
        
        let updatedSet = ExerciseSet(
            reps: currentSet.reps + 1,
            weight: currentSet.weight,
            isWarmupSet: currentSet.isWarmupSet,
            rpe: currentSet.rpe,
            notes: currentSet.notes,
            order: currentSet.order,
            isDone: currentSet.isDone
        )
        
        workout.updateCurrentSet(updatedSet)
        updateWorkoutActivity(workout: workout)
    }
    
    func decrementReps(workout: Workout) {
        guard currentActivity != nil else { return }
        workout.updateCurrentOrder()
        guard let currentSet = workout.currentSet else { return }
        
        let updatedSet = ExerciseSet(
            reps: max(1, currentSet.reps - 1),
            weight: currentSet.weight,
            isWarmupSet: currentSet.isWarmupSet,
            rpe: currentSet.rpe,
            notes: currentSet.notes,
            order: currentSet.order,
            isDone: currentSet.isDone
        )
        
        workout.updateCurrentSet(updatedSet)
        updateWorkoutActivity(workout: workout)
    }
    
    func moveToNextExercise(workout: Workout) {
        guard currentActivity != nil else { return }
        workout.moveToNextExercise()
        updateWorkoutActivity(workout: workout)
    }
    
    func moveToPreviousExercise(workout: Workout) {
        guard currentActivity != nil else { return }
        workout.moveToPreviousExercise()
        updateWorkoutActivity(workout: workout)
    }
}
