//
//  WorkoutHistoryDetail.swift
//  SupaSet
//
//  Created by Rishi Garg on 11/8/24.
//
import SwiftUI
struct WorkoutHistoryDetailView: View {
    let workout: Workout
    
    var body: some View {
        List {
            Section {
                LabeledContent("Date", value: workout.date.formatted(date: .long, time: .shortened))
                LabeledContent("Duration", value: formatDuration(workout.duration))
                if let volume = workout.totalVolume {
                    LabeledContent("Total Volume", value: "\(Int(volume))lbs")
                }
                LabeledContent("Notes", value: workout.notes)
            }
            
            Section("Exercises") {
                ForEach(workout.exercises.sorted(by: { $0.order < $1.order })) { exercise in
                    ExerciseHistoryRow(exercise: exercise)
                }
            }
        }
        .navigationTitle(workout.name)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}
