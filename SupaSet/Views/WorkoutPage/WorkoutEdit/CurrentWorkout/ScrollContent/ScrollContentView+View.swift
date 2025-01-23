//
//  File.swift
//  SupaSet
//
//  Created by Rishi Garg on 12/10/24.
//

import SwiftUI
extension ScrollContentView {
    var body: some View {
        NavigationStack{
            DraggableScrollContainer(
                content: VStack(spacing: 10) {
                    LazyVStack {
                        WorkoutInfoView(workout: workout)
                        ForEach(sortedExercises) { exercise in
                            ExerciseCardView(
                                workoutExercise: exercise,
                                selectedExercise: $selectedExercise,
                                selectedExerciseScale: $selectedExerciseScale,
                                selectedExerciseFrame: $selectedExerciseFrame,
                                offset: $offset,
                                hapticsTrigger: $hapticsTrigger,
                                initialScrollOffset: $initialScrollOffset,
                                lastActiveScrollId: $lastActiveScrollId,
                                dragging: $dragging,
                                parentBounds: $parentFrame,
                                exerciseFrames: $exerciseFrames,
                                onScroll: checkAndScroll,
                                onSwap: checkAndSwapItems
                            )
                            .id(exercise.id)
                            .opacity(selectedExercise?.id == exercise.id ? 0 : 1)
                            .onGeometryChange(for: CGRect.self) {
                                $0.frame(in: .global)
                            } action: { newValue in
                                if selectedExercise?.id == exercise.id {
                                    selectedExerciseFrame = newValue
                                }
                                exerciseFrames[exercise.id] = newValue
                            }
                        }
                        CancelFinishAddView(item: workout, show: $show, isNew: !workout.isFinished)
                            .opacity(dragging ? 0 : 1) // hide when reordering exercises
                    }
                    .scrollTargetLayout()
                },
                items: sortedExercises,
                selectedItem: $selectedExercise,
                selectedItemScale: $selectedExerciseScale,
                selectedItemFrame: $selectedExerciseFrame,
                offset: $offset,
                hapticsTrigger: $hapticsTrigger,
                initialScrollOffset: $initialScrollOffset,
                scrolledItem: $scrolledExercise,
                lastActiveScrollId: $lastActiveScrollId,
                dragging: $dragging,
                parentFrame: $parentFrame,
                itemFrames: $exerciseFrames,
                topRegion: $topRegion,
                bottomRegion: $bottomRegion,
                onScroll: checkAndScroll,
                onSwap: checkAndSwapItems
            )
            .sensoryFeedback(.impact, trigger: hapticsTrigger)
        }
    }
}
