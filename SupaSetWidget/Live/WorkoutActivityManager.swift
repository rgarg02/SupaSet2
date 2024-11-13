//
//  WorkoutActivityManager.swift
//  SupaSet
//
//  Created by Rishi Garg on 11/11/24.
//


import ActivityKit


// MARK: - Live Activity Manager
class WorkoutActivityManager {
    static let shared = WorkoutActivityManager()
    private var currentActivity: Activity<WorkoutAttributes>?
    
    func startWorkoutActivity(workout: Workout) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        
        let currentExercise = workout.currentExercise
        let currentSet = workout.currentSet
        
        let attributes = WorkoutAttributes(
            workoutId: workout.id.uuidString, workoutName: workout.name,
            startTime: workout.date
        )
        
        let contentState = WorkoutAttributes.ContentState(
            currentExerciseName: currentExercise?.exercise.name ?? "",
            currentSetNumber: workout.currentSetOrder + 1,
            totalSets: currentExercise?.sets.count ?? 0,
            weight: currentSet?.weight ?? 0,
            targetReps: currentSet?.reps ?? 0,
            isWarmupSet: currentSet?.isWarmupSet ?? false,
            exerciseNumber: workout.currentExerciseOrder + 1,
            totalExercises: workout.exercises.count
        )
        
        do {
            let activity = try Activity.request(
                attributes: attributes,
                contentState: contentState,
                pushType: nil
            )
            currentActivity = activity
        } catch {
            print("Error starting workout activity: \(error)")
        }
    }
    
    func updateWorkoutActivity(workout: Workout) {
        workout.updateCurrentOrder()
        guard let currentExercise = workout.currentExercise,
              let currentSet = workout.currentSet else { return }
        let contentState = WorkoutAttributes.ContentState(
            currentExerciseName: currentExercise.exercise.name,
            currentSetNumber: workout.currentSetOrder + 1,
            totalSets: currentExercise.sets.count,
            weight: currentSet.weight,
            targetReps: currentSet.reps,
            isWarmupSet: currentSet.isWarmupSet,
            exerciseNumber: workout.currentExerciseOrder + 1,
            totalExercises: workout.exercises.count
        )
        
        Task {
            await currentActivity?.update(using: contentState)
        }
    }
    // MARK: - Set Management
    func completeCurrentSet(workout: Workout) {
        // Ensure we're in the right state before making changes
        workout.updateCurrentOrder()
        
        // Complete the set
        workout.completeCurrentSet()
        
        // Update the live activity
        updateWorkoutActivity(workout: workout)
    }
    func moveToNextSet(workout: Workout) {
        workout.moveToNextSet()
        updateWorkoutActivity(workout: workout)
    }
    
    func moveToPreviousSet(workout: Workout) {
        guard workout.currentSetOrder > 0 else { return }
        
        workout.moveToPreviousSet()
        updateWorkoutActivity(workout: workout)
    }
    
    func incrementWeight(workout: Workout, by amount: Double = 5.0) {
        guard let currentSet = workout.currentSet else { return }
        
        // Create temporary set with new values
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
        workout.moveToNextExercise()
        print(workout.currentSetOrder)
        updateWorkoutActivity(workout: workout)
    }
    
    // Previous Exercise Update
    func moveToPreviousExercise(workout: Workout) {
        workout.moveToPreviousExercise()
        updateWorkoutActivity(workout: workout)
    }
    
    
    func endWorkoutActivity() {
        Task {
            await currentActivity?.end(using: currentActivity?.contentState, dismissalPolicy: .immediate)
        }
    }
}

