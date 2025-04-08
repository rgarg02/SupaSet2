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
    @State private var currentTime = Date()
    var timeInterval: TimeInterval {
        abs(workout.date.timeIntervalSince(currentTime))
    }
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var formattedTime: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: timeInterval) ?? "00:00:00"
    }
    
    var body: some View {
        HStack(spacing: 8) {
            // Timer Display
            Text(formattedTime)
                .monospacedDigit()
                .font(.system(.body, design: .rounded, weight: .semibold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [ .accent.adjusted(by: -50), .accent],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background {
                    Capsule()
                        .fill(.thickMaterial)
                        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                }
                .contentTransition(.numericText(countsDown: true))
        }
        .onReceive(timer) { time in
            currentTime = time
        }
    }
}

#Preview {
    let preview = PreviewContainer.preview
    WorkoutTimer(workout: preview.workout)
        .modelContainer(preview.container)
        .colorScheme(.light)
    WorkoutTimer(workout: preview.workout)
        .modelContainer(preview.container)
        .colorScheme(.dark)
}
