//
//  File.swift
//  SupaSet
//
//  Created by Rishi Garg on 12/10/24.
//

import SwiftUI
extension ScrollContentView {
    var body: some View {
        ZStack {
            ScrollView {
                LazyVStack {
                    WorkoutInfoView(workout: workout, focused: focused)
                        .padding(.top, -20)
                    ForEach(sortedExercises) { exercise in
                        ExerciseCardView(
                            workout: workout,
                            workoutExercise: exercise,
                            focused: focused,
                            selectedExercise: $selectedExercise,
                            selectedExerciseScale: $selectedExerciseScale,
                            selectedExerciseFrame: $selectedExerciseFrame,
                            offset: $offset,
                            hapticsTrigger: $hapticsTrigger,
                            initialScrollOffset: $initialScrollOffset,
                            lastActiveScrollId: $lastActiveScrollId,
                            dragging: $dragging,
                            parentBounds: $parentFrame,
                            minimizing: minimizing,
                            exerciseFrames: $exerciseFrames,
                            onScroll: checkAndScroll,
                            onSwap: checkAndSwapItems
                        )
                        .opacity(selectedExercise?.id == exercise.id ? 0 : 1)
                        .onGeometryChange(for: CGRect.self) {
                            $0.frame(in: .global)
                        } action: { newValue in
                            if !minimizing {
                                if selectedExercise?.id == exercise.id {
                                    selectedExerciseFrame = newValue
                                }
                                exerciseFrames[exercise.id] = newValue
                            }
                        }
                    }
                }
                .padding(.bottom, sortedExercises.last.flatMap { (exerciseFrames[$0.id]?.height ?? 0)/2 } ?? 0)
                .scrollTargetLayout()
            }
            .scrollIndicators(.hidden)
            .scrollPosition(id: $scrolledExercise)
            .contentMargins(.vertical, 30)
            .scrollTargetBehavior(.viewAligned)
            .padding(.horizontal, 20)
            .overlay(alignment: .trailing) {
                if dragging {
                    if let selectedExercise {
                        WorkoutProgressDots(totalExercises: exercises.count, currentExerciseIndex: sortedExercises.firstIndex(where: {$0.id == selectedExercise.id}) ?? 0)
                            .padding(.trailing, 10)
                    }
                    
                }else{
                    WorkoutProgressDots(totalExercises: exercises.count, currentExerciseIndex: sortedExercises.firstIndex(where: {$0.id == scrolledExercise}) ?? 0)
                        .padding(.trailing, 10)
                }
            }
            .onGeometryChange(for: CGRect.self) {
                $0.frame(in: .global)
            } action: { newValue in
                // Only update if the frame actually changed significantly
                if abs(parentFrame.minY - newValue.minY) > 1 {
                    parentFrame = newValue
                }
            }
            .overlay(alignment: .top) {
                Rectangle()
                    .fill(.clear)
                    .frame(height: 100)
                    .onGeometryChange(for: CGRect.self) {
                        $0.frame(in: .global)
                    } action: { newValue in
                        topRegion = newValue
                    }
            }
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(.clear)
                    .frame(height: 100)
                    .onGeometryChange(for: CGRect.self) {
                        $0.frame(in: .global)
                    } action: { newValue in
                        bottomRegion = newValue
                    }
            }
            .overlay(alignment: .topLeading) {
                let adjustedInitialOffset = CGRect(
                                    x: initialScrollOffset.minX,
                                    y: initialScrollOffset.minY - parentFrame.minY,
                                    width: initialScrollOffset.width,
                                    height: initialScrollOffset.height
                                )
                if let selectedExercise {
                    ExerciseCardView(
                        workout: workout,
                        workoutExercise: selectedExercise,
                        focused: focused,
                        selectedExercise: $selectedExercise,
                        selectedExerciseScale: $selectedExerciseScale,
                        selectedExerciseFrame: $selectedExerciseFrame,
                        offset: $offset,
                        hapticsTrigger: $hapticsTrigger,
                        initialScrollOffset: $initialScrollOffset,
                        lastActiveScrollId: $lastActiveScrollId,
                        dragging: $dragging,
                        parentBounds: $parentFrame,
                        minimizing: minimizing,
                        exerciseFrames: $exerciseFrames,
                        onScroll: checkAndScroll,
                        onSwap: checkAndSwapItems
                    )
                    .frame(width: exerciseFrames[selectedExercise.id]?.width ?? .zero, height: exerciseFrames[selectedExercise.id]?.height ?? .zero)
                    .scaleEffect(selectedExerciseScale)
                    .offset(x: adjustedInitialOffset.minX,
                            y: adjustedInitialOffset.minY)
                    .offset(offset)
                    .ignoresSafeArea()
                    .transition(.identity)
                }
            }
        }
        .sensoryFeedback(.impact, trigger: hapticsTrigger)
    }
}
