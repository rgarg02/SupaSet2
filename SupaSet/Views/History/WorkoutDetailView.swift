//
//  WorkoutDetailView.swift
//  SupaSet
//
//  Created by Rishi Garg on 1/26/25.
//


import SwiftUI
// Workout Detail View
struct WorkoutDetailView: View {
    let workout: Workout
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                MuscleIntensityView(workout: workout)
                // Header Stats
                headerStats
                if !workout.notes.isEmpty {
                    notesSection
                }
                // Exercise List
                exerciseList
            }
            .padding()
        }
        .navigationTitle(workout.name)
        .background(Color(.systemGroupedBackground))
    }
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Notes", systemImage: "note.text")
                .font(.headline)
                .foregroundColor(.theme.text)
            
            Text(workout.notes)
                .font(.body)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }
    private var headerStats: some View {
        VStack(spacing: 16) {
            HStack {
                Text(formatDate(workout.date))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
            }
            
            HStack {
                StatBox(
                    title: "Duration",
                    value: formatDuration(workout.duration),
                    icon: "clock.fill"
                )
                
                StatBox(
                    title: "Exercises",
                    value: "\(workout.exercises.count)",
                    icon: "dumbbell.fill"
                )
                
                if let volume = workout.totalVolume {
                    StatBox(
                        title: "Total Volume",
                        value: String(format: "%.1f", volume),
                        icon: "chart.bar.fill"
                    )
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
    
    private var exerciseList: some View {
        ForEach(workout.exercises.sorted(by: { $0.order < $1.order }), id: \.id) { exercise in
            ExerciseCard(exercise: exercise)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: date)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration / 60)
        return "\(minutes) min"
    }
}

#Preview {
    let preview = PreviewContainer.preview
    WorkoutDetailView(workout: preview.workout)
        .environment(preview.viewModel)
        .modelContainer(preview.container)
}
