//
//  SupaSetApp.swift
//  SupaSet
//
//  Created by Rishi Garg on 11/5/24.
//

import SwiftUI
import SwiftData

@main
struct SupaSetApp: App {
    let container: ModelContainer
    
    init() {
        let schema = Schema([
            Workout.self,
            WorkoutExercise.self,
            ExerciseSet.self
        ])
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true 
        )
        
        do {
            container = try ModelContainer(
                for: schema,
                configurations: modelConfiguration
            )
        } catch {
            fatalError("Could not initialize ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(container)
        }
    }
}
