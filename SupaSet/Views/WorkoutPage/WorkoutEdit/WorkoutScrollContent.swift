//
//  WorkoutScrollContent.swift
//  SupaSet
//
//  Created by Rishi Garg on 11/21/24.
//

import SwiftUI

struct WorkoutScrollContent: View {
    @Bindable var workout: Workout
    @Binding var scrolledExercise: Int?
    var focused: FocusState<Bool>.Binding
    var scrollOffset: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack {
                    WorkoutInfoView(workout: workout)
                        .padding(.top, -50)
                    
                    ForEach(workout.sortedExercises, id: \.self) { exercise in
                        ExerciseCardView(
                            workout: workout,
                            workoutExercise: exercise,
                            focused: focused
                        )
                        .scrollTransition { content, phase in
                            content
                                .opacity(phase.isIdentity ? 1 : 0.8)
                                .scaleEffect(phase.isIdentity ? 1 : 0.9)
                        }
                        .containerRelativeFrame(.vertical, count: 1, spacing: 10)
                        .id(exercise.order)
                    }
                }
                .scrollTargetLayout()
                .scrollOffsetTracking(scrollOffset: scrollOffset)
            }
            .padding(.horizontal, 20)
            .contentMargins(.vertical, 50)
            .scrollTargetBehavior(.viewAligned)
            .overlay(alignment: .trailing) {
                WorkoutProgressDots(
                    totalExercises: workout.exercises.count,
                    currentExerciseIndex: scrolledExercise ?? 0
                )
            }
            .scrollIndicators(.hidden)
            .scrollPosition(id: $scrolledExercise)
        }
    }
}
