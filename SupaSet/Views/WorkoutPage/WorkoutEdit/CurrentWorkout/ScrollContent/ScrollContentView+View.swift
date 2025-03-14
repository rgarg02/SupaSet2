// DragState.swift - A new file to contain our consolidated state
import SwiftUI

// Centralized state management for drag operations

// ScrollContentView.swift - Simplified extension
extension ScrollContentView {
    var body: some View {
        NavigationStack {
            DraggableScrollContainer(
                content: {
                    LazyVStack(spacing: 10) {
                        WorkoutInfoView(workout: workout)
                        ForEach(sortedExercises) { exercise in
                            ExerciseCardView(exercise: exercise)
                                .id(exercise.id)
                                .opacity(dragState.selectedExercise?.id == exercise.id ? 0 : 1)
                                .measureFrame { newFrame in
                                    dragState.itemFrames[exercise.id] = newFrame
                                    if dragState.selectedExercise?.id == exercise.id {
                                        dragState.selectedItemFrame = newFrame
                                    }
                                }
                        }
                        if !dragState.isDragging {
                            CancelFinishAddView(
                                item: workout,
                                originalItem: workout,
                                show: $show,
                                isNew: !workout.isFinished
                            )
                        }
                    }
                    .scrollTargetLayout()
                },
                items: sortedExercises
            )
            .environmentObject(dragState)
            .sensoryFeedback(.impact, trigger: dragState.hapticFeedback)
        }
        .onChange(of: dragState.isDragging) { _, _ in
            WorkoutActivityManager.shared.updateWorkoutActivity(workout: workout)
        }
    }
}


