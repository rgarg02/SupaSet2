//
//  ProfileStatsView.swift
//  SupaSet
//
//  Created by Rishi Garg on 4/2/25.
//
import SwiftUI

struct ProfileStatsView: View {
    let workoutCount: Int
    let totalHours: Int
    let weeklyStreak: Int

    var body: some View {
        HStack(spacing: 15) { // Adjusted spacing
            StatCard(title: "Workouts", value: "\(workoutCount)", icon: "figure.run", delay: 0.0) // Changed icon
            StatCard(title: "Hours", value: "\(totalHours)", icon: "clock.fill", delay: 0.1) // Adjusted delay
            StatCard(title: "Streak", value: "\(weeklyStreak) \(weeklyStreak == 1 ? "wk" : "wks")", icon: "flame.fill", delay: 0.2) // Adjusted delay & text
        }
        .foregroundColor(.text) // Added fallback
    }
}

// Preview for the Stats View
#Preview {
    ProfileStatsView(workoutCount: 15, totalHours: 25, weeklyStreak: 3)
        .padding()
        .background(Color.gray.opacity(0.1))
}
