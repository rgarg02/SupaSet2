//
//  WorkoutTimer.swift
//  SupaSet
//
//  Created by Rishi Garg on 11/21/24.
//
import SwiftUI

// MARK: - WorkoutTimer
struct WorkoutTimer: View {
    let workout: Workout
    
    var body: some View {
        HStack {
            if #available(iOS 18.0, *){
                Image(systemName: "clock")
                    .foregroundStyle(Color.theme.accent)
                    .symbolEffect(.breathe)
            }else{
                Image(systemName: "clock")
                    .foregroundStyle(Color.theme.accent)
            }
            
            Text(
                Date(
                    timeIntervalSinceNow: Double(
                        workout.date.timeIntervalSince1970
                    ) - Date().timeIntervalSince1970
                ),
                style: .timer
            )
            .contentTransition(.numericText(countsDown: true))
        }
    }
}

#Preview {
    let preview = PreviewContainer.preview
    WorkoutTimer(workout: preview.workout)
        .modelContainer(preview.container)
}
