//
//  ExerciseListRow.swift
//  SupaSet
//
//  Created by Rishi Garg on 11/23/24.
//
import SwiftUI

struct ExerciseListRow: View {
    let exercise: WorkoutExercise
    @Environment(ExerciseViewModel.self) var viewModel
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                
                HStack{
                    Text("\(exercise.order + 1). ")
                        .font(.title3)
                        .foregroundColor(.theme.accent)
                    Text(viewModel.getExerciseName(for: exercise.exerciseID))
                        .font(.title3.bold())
                        .foregroundColor(.theme.primary)
                    
                }
                
                Text("^[\(exercise.sets.count) sets](inflect: true)")
                    .font(.subheadline)
                    .foregroundColor(.theme.secondary)
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .contentShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color.theme.accent.opacity(0.3), lineWidth: 2)
        )
        .shadow(color: Color.theme.accent.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

#Preview("Exercise List Row") {
    let preview = PreviewContainer.preview
    ExerciseListRow(exercise: preview.workout.sortedExercises[0])
        .padding()
//        .background(Color.theme.secondary)
        .modelContainer(preview.container)
}


