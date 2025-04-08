//
//  MenuLink.swift
//  SupaSet
//
//  Created by Rishi Garg on 1/27/25.
//


import SwiftUI
struct MenuLink<Destination: View>: View {
    let title: String
    let icon: String
    let destination: Destination
    var body: some View {
        NavigationLink {
            destination
        } label: {
            HStack {
                Image(systemName: icon)
                    .frame(width: 24)
                    .foregroundColor(Color.theme.accent)
                
                Text(title)
                    .foregroundColor(.theme.text)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(
                .thinMaterial
            )
            .cornerRadius(12)
        }
    }
}
#Preview {
    MenuLink(title: "Your Workouts", icon: "list.bullet", destination: AnyView(Text("Workouts")))
}
struct ProfileMenuView: View {
    var body: some View {
        VStack(spacing: 10) { // Adjusted spacing
            // Add other menu items here if needed
            MenuLink(title: "Progress & Stats", icon: "chart.bar.xaxis", destination: WorkoutStatsView())
            // Example: MenuLink(title: "Achievements", icon: "star.fill", destination: AchievementsView())
        }
        .foregroundColor(.text) // Added fallback
    }
}
