//
//  LiveActivityManager.swift
//  SupaSet
//
//  Created by Rishi Garg on 11/9/24.
//

import ActivityKit
import Foundation

class LiveActivityManager {
    @discardableResult
    static func startActivity(currentExerciseName: String, workoutStartTime: Date, setNumber: Int) throws -> String {
        var activity: Activity<WorkoutAttributes>?
        let initialState =  WorkoutAttributes.ContentState(workoutStartTime: workoutStartTime, currentExerciseName: currentExerciseName, setNumber: setNumber)
        do {
            activity = try Activity.request(attributes: WorkoutAttributes(), contentState: initialState, pushType: nil)
            
            guard let id = activity?.id else { throw
                LiveActivityErrorType.failedToGetID }
            return id
        } catch {
            throw error
        }
    }
    static func listAllActivities() -> [[String:String]] {
        let sortedActivities = Activity<WorkoutAttributes>.activities.sorted{ $0.id > $1.id }
        
        return sortedActivities.map {
            [
                "id": $0.id,
                "workoutStartTime": $0.contentState.workoutStartTime.description,
                "currentExerciseName": $0.contentState.currentExerciseName,
                "setNumber": $0.contentState.setNumber.description
            ]
        }
    }
    
    static func endAllActivities() async {
        for activity in Activity<WorkoutAttributes>.activities {
            await activity.end(dismissalPolicy: .immediate)
        }
    }
    
    static func endActivity(_ id: String) async {
        await Activity<WorkoutAttributes>.activities.first(where: {
            $0.id == id
        })?.end(dismissalPolicy: .immediate)
    }
    static func updateActivity(
            id: String? = nil,
            workoutStartTime: Date,
            currentExerciseName: String,
            setNumber: Int
        ) async throws {
            let updatedContentState = WorkoutAttributes.ContentState(
                workoutStartTime: workoutStartTime,
                currentExerciseName: currentExerciseName,
                setNumber: setNumber
            )
            
            let activity: Activity<WorkoutAttributes>?
            
            if let id = id {
                // Update specific activity if ID is provided
                activity = Activity<WorkoutAttributes>.activities.first(where: { $0.id == id })
            } else {
                // Update most recent activity if no ID is provided
                activity = Activity<WorkoutAttributes>.activities.sorted { $0.id > $1.id }.first
            }
            
            guard let activity = activity else {
                throw LiveActivityErrorType.failedToGetID
            }
            
            await activity.update(using: updatedContentState)
        }
}
enum LiveActivityErrorType: Error {
    case failedToGetID
}
