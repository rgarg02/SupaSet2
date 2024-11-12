//
//  AppIntentmain.swift
//  SupaSet
//
//  Created by Rishi Garg on 11/11/24.
//

import AppIntents
import SwiftData

// MARK: - Previous Exercise Intent
struct PreviousExerciseIntent: AppIntent, LiveActivityIntent {
    static var title: LocalizedStringResource = "Previous Exercise"
    
    @Parameter(title: "Workout ID")
    var workoutId: String
    
    init() {}
    init(workoutId: String) {
        self.workoutId = workoutId }
    
    @MainActor
    func perform() async throws -> some IntentResult {
        print("Here")
        guard let uuid = UUID(uuidString: workoutId) else{
            print("cant find id")
            return .result()
        }
        let modelContainer = AppContainer.shared.container

        let workouts = try? modelContainer!.mainContext.fetch(FetchDescriptor<Workout>())
        print("Fetched workouts: \(workouts?.count ?? 0)") // Debug output

        guard let workout = workouts?.first(where: { $0.id == uuid }) else {
            print("No workout found with id \(workoutId)")
            return .result()
        }
        print(workout.name)
        WorkoutActivityManager.shared.moveToPreviousExercise(workout: workout)
        return .result()
    }
}
// MARK: - Next Exercise Intent
struct NextExerciseIntent: AppIntent, LiveActivityIntent {
    static var title: LocalizedStringResource = "Next Exercise"
    
    @Parameter(title: "Workout ID")
    var workoutId: String
    
    init() {}
    init(workoutId: String) { self.workoutId = workoutId }
    
    @MainActor
    func perform() async throws -> some IntentResult {
        
        print("Here")
        guard let uuid = UUID(uuidString: workoutId) else{
            print("cant find id")
            return .result()
        }
        let modelContainer = AppContainer.shared.container

        let workouts = try? modelContainer!.mainContext.fetch(FetchDescriptor<Workout>())
        print("Fetched workouts: \(workouts?.count ?? 0)") // Debug output

        guard let workout = workouts?.first(where: { $0.id == uuid }) else {
            print("No workout found with id \(workoutId)")
            return .result()
        }
        print(workout.name)
        WorkoutActivityManager.shared.moveToNextExercise(workout: workout)
        return .result()
    }
}
