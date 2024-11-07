//
//  ExerciseCardView.swift
//  SupaSet
//
//  Created by Rishi Garg on 11/7/24.
//

import SwiftUI

struct ExerciseCardView: View {
    let workoutExercise: WorkoutExercise
    private var orderedSets: [ExerciseSet] {
        return workoutExercise.sets.sorted { $0.order < $1.order }
    }
    @FocusState.Binding var focused : Bool
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(workoutExercise.exercise.name)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.theme.text)
            HStack(spacing: 16) {
                Text("SET")
                    .font(.caption)
                    .foregroundColor(.theme.text)
                    .frame(width: 30)
                
                Text("WEIGHT")
                    .font(.caption)
                    .foregroundColor(.theme.text)
                    .frame(width: 80)
                
                Text("REPS")
                    .font(.caption)
                    .foregroundColor(.theme.text)
                    .frame(width: 80)
                
                Spacer()
                
                Text("DONE")
                    .font(.caption)
                    .foregroundColor(.theme.text)
                    .frame(width: 50)
            }
            .padding(.horizontal, 16)
            VStack(spacing: 8) {
                ForEach(orderedSets, id: \.self) { set in
                    SetRowView(
                        setNumber: set.order + 1,
                        set: set,
                        focused: $focused
                    )
                }
            }
            Spacer()
            CustomButton(icon: "plus", title: "Add Set", size: .small, style: .filled()) {
                let nextOrder = (orderedSets.last?.order ?? -1) + 1
                let newSet = ExerciseSet(
                    reps: orderedSets.last?.reps ?? 0,
                    weight: orderedSets.last?.weight ?? 0,
                    order: nextOrder
                )
                workoutExercise.sets.append(newSet)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.theme.background)
                .shadow(
                    color: Color.black.opacity(0.1),
                    radius: 5,
                    x: 0,
                    y: 2
                )
                .padding(8)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.theme.accent, lineWidth: 1)
                .padding(8)
        )
    }
}

//#Preview {
//    // Create a sample exercise for preview
//    let exercise = Exercise(
//        id: "bench-press",
//        name: "Bench Press",
//        level: .intermediate,
//        primaryMuscles: [.chest],
//        secondaryMuscles: [.shoulders, .triceps],
//        instructions: ["Bench press instructions"],
//        category: .strength,
//        images: []
//    )
//    
//    let workoutExercise = WorkoutExercise(exercise: exercise)
//    
//    return VStack {
//        ExerciseCardView(workoutExercise: workoutExercise)
//            .padding()
//        
//    }
//}
