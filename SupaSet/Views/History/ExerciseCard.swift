//
//  ExerciseCard.swift
//  SupaSet
//
//  Created by Rishi Garg on 1/26/25.
//


import SwiftUI
// Exercise Card Component
struct ExerciseCard: View {
    let exercise: WorkoutExercise
    @Environment(ExerciseViewModel.self) private var viewModel
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(viewModel.getExerciseName(for: exercise.exerciseID))
                .font(.headline)
            
            ForEach(exercise.sets.sorted(by: { $0.order < $1.order }), id: \.id) { set in
                HStack {
                    Text("Set \(set.order + 1)")
                        .foregroundColor(.secondary)
                    Spacer()
                    // Set Details with equal spacing using grid
                    Text("\(set.reps) reps")
                    Text("x")
                    Text("\(Int(set.weight))lbs")
                    Image(systemName: set.isDone ? "checkmark.circle.fill" :
                            "circle")
                    .foregroundColor(set.isDone ? .theme.secondary : .theme.cancel)
                }
                .font(.subheadline)
            }
            
            if let notes = exercise.notes {
                Text(notes)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}