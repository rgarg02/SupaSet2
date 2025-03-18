//
//  WorkoutHistoryCard.swift
//  SupaSet
//
//  Created by Rishi Garg on 1/26/25.
//


import SwiftUI
// Workout History Card Component
struct WorkoutHistoryCard: View {
    let workout: Workout
    @Environment(\.isChildPresenting) private var isChildPresenting
    var body: some View {
        NavigationLink(destination: WorkoutDetailView(workout: workout)
            .onAppear{
                isChildPresenting.wrappedValue = true
            }
        ) {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    Text(workout.name)
                        .font(.title3)
                        .bold()
                    Spacer()
                }
                
                // Date and Duration
                HStack {
                    Label(formatDate(workout.date), systemImage: "calendar")
                    Spacer()
                    Label(formatDuration(workout.duration), systemImage: "clock")
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
                
                // Stats
                HStack(spacing: 16) {
                    workoutStat(
                        title: "Exercises",
                        value: "\(workout.exercises.count)",
                        icon: "dumbbell"
                    )
                    
                    workoutStat(
                        title: "Volume",
                        value: String(format: "%.1f", workout.totalVolume),
                        icon: "chart.bar.fill"
                    )
                    
                }
            }
            .padding()
            .background(Color.theme.background)
            .cornerRadius(8)
            .shadow(
                color: Color.theme.text.opacity(0.3),
                radius: 2
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func workoutStat(title: String, value: String, icon: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(.theme.accent)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.callout)
                    .bold()
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration / 60)
        return "\(minutes) min"
    }
}

#Preview {
    let preview = PreviewContainer.preview
    WorkoutHistoryCard(workout: preview.workout)
        .environment(preview.viewModel)
        .modelContainer(preview.container)
}
