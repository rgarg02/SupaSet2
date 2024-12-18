//
//  ExerciseHistoryRow.swift
//  SupaSet
//
//  Created by Rishi Garg on 11/8/24.
//
import SwiftUI
struct ExerciseHistoryRow: View {
    let exercise: WorkoutExercise
    @Environment(ExerciseViewModel.self) var viewModel
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(viewModel.getExerciseName(for: exercise.exerciseID))
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 4) {
                ForEach(exercise.sets.sorted(by: { $0.order < $1.order })) { set in
                    HStack {
                        if set.isWarmupSet {
                            Text("Warmup")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Text("\(Int(set.weight))lbs × \(set.reps)")
                        if let rpe = set.rpe {
                            Text("RPE: \(rpe)")
                                .foregroundStyle(.secondary)
                        }
                        if let notes = set.notes, !notes.isEmpty {
                            Text("📝")
                                .help(notes)
                        }
                    }
                    .font(.subheadline)
                }
            }
            
            if let notes = exercise.notes, !notes.isEmpty {
                Text(notes)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Text("Total Volume: \(Int(exercise.totalVolume))lbs")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}
