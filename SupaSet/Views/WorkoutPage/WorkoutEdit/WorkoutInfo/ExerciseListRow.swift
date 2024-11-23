//
//  ExerciseListRow.swift
//  SupaSet
//
//  Created by Rishi Garg on 11/23/24.
//
import SwiftUI

struct ExerciseListRow: View {
    let exercise: WorkoutExercise
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                
                HStack{
                    Text("\(exercise.order + 1). ")
                        .font(.title3)
                        .foregroundColor(.theme.accent)
                    Text(exercise.exercise.name)
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
    }
}

#Preview("Exercise List Row") {
    let preview = PreviewContainer.preview
    ExerciseListRow(exercise: preview.workout.sortedExercises[0])
        .padding()
//        .background(Color.theme.secondary)
        .modelContainer(preview.container)
}


