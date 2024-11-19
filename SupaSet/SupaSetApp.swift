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
           do {
               let storeURL = URL.documentsDirectory.appending(path: "SupaSet.sqlite")
               let config = ModelConfiguration(url: storeURL)
               container = try ModelContainer(for: schema, configurations: config)
           } catch {
               fatalError("Failed to configure SwiftData container.")
           }
       }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(container)
                .onAppear {
                    AppContainer.shared.container = container
                    WorkoutActivityManager.shared.endAllActivities()
                }
        }
    }
}

