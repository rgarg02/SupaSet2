//
//  AppIntentmain.swift
//  SupaSet
//
//  Created by Rishi Garg on 11/11/24.
//

import AppIntents
import SwiftData

// MARK: - Previous Exercise Intent
struct CompleteSetIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Complete Current Set"
    
    @Parameter(title: "Workout ID")
    var workoutId: String
    
    init() {}
    init(workoutId: String) {
        self.workoutId = workoutId }
    
    @MainActor
    func perform() async throws -> some IntentResult {
        guard let uuid = UUID(uuidString: workoutId) else{
            return .result()
        }
        let container = AppContainer.shared.container
        
        do {
            let descriptor = FetchDescriptor<Workout>()
            let workouts = try container.mainContext.fetch(descriptor)
            
            guard let workout = workouts.first(where: { $0.id == uuid }) else {
                print("No workout found with id \(workoutId)")
                return .result()
            }
            
            WorkoutActivityManager.shared.completeCurrentSet(workout: workout)
            return .result()
        } catch {
            print("Error fetching workouts: \(error)")
            return .result()
        }
    }
}
// MARK: - Weight Adjustment Intents
struct IncrementWeightIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Increment Weight"
    
    @Parameter(title: "Workout ID")
    var workoutId: String
    
    init() {}
    
    init(workoutId: String) {
        self.workoutId = workoutId
    }
    
    @MainActor
    func perform() async throws -> some IntentResult {
        guard let uuid = UUID(uuidString: workoutId) else {
            return .result()
        }
        
        let context = AppContainer.shared.container.mainContext
        
        do {
            let descriptor = FetchDescriptor<Workout>(
                predicate: #Predicate<Workout> { workout in
                    workout.id == uuid
                }
            )
            
            let workouts = try context.fetch(descriptor)
            guard let workout = workouts.first else {
                print("No workout found with id \(workoutId)")
                return .result()
            }
            print(workout.currentSetOrder)
            // Ensure we're operating within the correct context
            WorkoutActivityManager.shared.incrementWeight(workout: workout)
            
            try context.save()
            return .result()
        } catch {
            print("Error in increment weight intent: \(error)")
            return .result()
        }
    }
}

struct DecrementWeightIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Decrement Weight"
    
    @Parameter(title: "Workout ID")
    var workoutId: String
    
    init() {}
    
    init(workoutId: String) {
        self.workoutId = workoutId
    }
    
    @MainActor
    func perform() async throws -> some IntentResult {
        guard let uuid = UUID(uuidString: workoutId) else{
            return .result()
        }
        let container = AppContainer.shared.container
        
        do {
            let descriptor = FetchDescriptor<Workout>()
            let workouts = try container.mainContext.fetch(descriptor)
            
            guard let workout = workouts.first(where: { $0.id == uuid }) else {
                print("No workout found with id \(workoutId)")
                return .result()
            }
            
            WorkoutActivityManager.shared.decrementWeight(workout: workout)
            return .result()
        } catch {
            print("Error fetching workouts: \(error)")
            return .result()
        }
    }
}

// MARK: - Reps Adjustment Intents
struct IncrementRepsIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Increment Reps"
    
    @Parameter(title: "Workout ID")
    var workoutId: String
    
    init() {}
    
    init(workoutId: String) {
        self.workoutId = workoutId
    }
    
    @MainActor
    func perform() async throws -> some IntentResult {
        guard let uuid = UUID(uuidString: workoutId) else{
            return .result()
        }
        let container = AppContainer.shared.container
        
        do {
            let descriptor = FetchDescriptor<Workout>()
            let workouts = try container.mainContext.fetch(descriptor)
            
            guard let workout = workouts.first(where: { $0.id == uuid }) else {
                print("No workout found with id \(workoutId)")
                return .result()
            }
            
            WorkoutActivityManager.shared.incrementReps(workout: workout)
            return .result()
        } catch {
            print("Error fetching workouts: \(error)")
            return .result()
        }
    }
}

struct DecrementRepsIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Decrement Reps"
    
    @Parameter(title: "Workout ID")
    var workoutId: String
    
    init() {}
    
    init(workoutId: String) {
        self.workoutId = workoutId
    }
    
    @MainActor
    func perform() async throws -> some IntentResult {
        guard let uuid = UUID(uuidString: workoutId) else{
            return .result()
        }
        let container = AppContainer.shared.container
        
        do {
            let descriptor = FetchDescriptor<Workout>()
            let workouts = try container.mainContext.fetch(descriptor)
            
            guard let workout = workouts.first(where: { $0.id == uuid }) else {
                print("No workout found with id \(workoutId)")
                return .result()
            }
            
            WorkoutActivityManager.shared.decrementReps(workout: workout)
            return .result()
        } catch {
            print("Error fetching workouts: \(error)")
            return .result()
        }
    }
}