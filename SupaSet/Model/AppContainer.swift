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
        let schema = Schema([
            Workout.self,
            WorkoutExercise.self,
            ExerciseSet.self,
            ExerciseDetail.self,
            Template.self,
            TemplateExercise.self,
            TemplateExerciseSet.self,
            ExerciseEntity.self
        ])
           do {
               let storeURL = URL.documentsDirectory.appending(path: "SupaSet.sqlite")
               let config = ModelConfiguration(url: storeURL)
               return try ModelContainer(for: schema, configurations: config)
           } catch {
               fatalError("Failed to configure SwiftData container.")
           }
    }()
    
    private init() {} // Ensure singleton pattern
}
