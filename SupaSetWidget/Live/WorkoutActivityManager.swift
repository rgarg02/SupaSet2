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
        guard let currentExercise = workout.currentExercise,
              let currentSet = workout.currentSet else { return }
        print(currentExercise)
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

