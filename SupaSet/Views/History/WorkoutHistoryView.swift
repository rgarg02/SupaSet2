//
//  WorkoutHistoryView.swift
//  SupaSet
//
//  Created by Rishi Garg on 11/8/24.
//

import SwiftUI
import SwiftData

struct WorkoutHistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<Workout> { workout in
        workout.isFinished == true
    }, sort: \Workout.date, order: .reverse) private var completedWorkouts: [Workout]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(completedWorkouts) { workout in
                    NavigationLink(destination: WorkoutHistoryDetailView(workout: workout)) {
                        WorkoutHistoryRow(workout: workout)
                    }
                }
            }
            .navigationTitle("Workout History")
            .overlay {
                if completedWorkouts.isEmpty {
                    ContentUnavailableView(
                        "No Completed Workouts",
                        systemImage: "dumbbell",
                        description: Text("Complete your first workout to see it here")
                    )
                }
            }
        }
    }
}

#Preview {
    let previewContainer = PreviewContainer.preview
    WorkoutHistoryView()
        .modelContainer(previewContainer.container)
}
