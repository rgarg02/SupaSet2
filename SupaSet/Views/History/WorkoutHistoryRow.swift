//
//  WorkoutHistoryRow.swift
//  SupaSet
//
//  Created by Rishi Garg on 11/8/24.
//

import SwiftUI
struct WorkoutHistoryRow: View {
    let workout: Workout
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(workout.name)
                .font(.headline)
            
            HStack {
                Label("\(workout.exercises.count) exercises", systemImage: "dumbbell")
                Spacer()
                Text(workout.date.formatted(date: .abbreviated, time: .shortened))
                    .foregroundStyle(.secondary)
            }
            .font(.subheadline)
            
            Text(formatDuration(workout.duration))
                .font(.caption)
                .foregroundStyle(.secondary)
            
            if let volume = workout.totalVolume {
                Text("Total Volume: \(Int(volume))lbs")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
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
