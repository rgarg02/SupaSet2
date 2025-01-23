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
    static var isDiscoverable: Bool = false
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
                return .result()
            }
            
            WorkoutActivityManager.shared.completeCurrentSet(workout: workout)
            return .result()
        } catch {
            return .result()
        }
    }
}
// MARK: - Weight Adjustment Intents
struct IncrementWeightIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Increment Weight"
    static var isDiscoverable: Bool = false
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
                return .result()
            }
            // Ensure we're operating within the correct context
            WorkoutActivityManager.shared.incrementWeight(workout: workout)
            
            try context.save()
            return .result()
        } catch {
            return .result()
        }
    }
}

struct DecrementWeightIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Decrement Weight"
    static var isDiscoverable: Bool = false
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
                return .result()
            }
            
            WorkoutActivityManager.shared.decrementWeight(workout: workout)
            return .result()
        } catch {
            return .result()
        }
    }
}

// MARK: - Reps Adjustment Intents
struct IncrementRepsIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Increment Reps"
    static var isDiscoverable: Bool = false
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
                return .result()
            }
            
            WorkoutActivityManager.shared.incrementReps(workout: workout)
            return .result()
        } catch {
            return .result()
        }
    }
}

struct DecrementRepsIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Decrement Reps"
    static var isDiscoverable: Bool = false
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
                return .result()
            }
            
            WorkoutActivityManager.shared.decrementReps(workout: workout)
            return .result()
        } catch {
            return .result()
        }
    }
}
