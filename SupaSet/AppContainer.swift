//
//  AppContainer.swift
//  SupaSet
//
//  Created by Rishi Garg on 11/11/24.
//

import SwiftData
import Foundation

// Create a singleton or static container for global access
class AppContainer {
    static let shared = AppContainer()
    
    lazy var container: ModelContainer = {
        do {
            let schema = Schema([
                Workout.self,
                WorkoutExercise.self,
                ExerciseSet.self
            ])
            let storeURL = URL.documentsDirectory.appending(path: "SupaSet.sqlite")
            let config = ModelConfiguration(url: storeURL)
            // Make sure to include all your model types here
            return try ModelContainer(for: schema, configurations: config)
        } catch {
            fatalError("Failed to configure SwiftData container: \(error)")
        }
    }()
    
    private init() {} // Ensure singleton pattern
}
