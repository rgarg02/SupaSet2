//
//  ScrollContentView.swift
//  SupaSet
//
//  Created by Rishi Garg on 11/24/24.
//

import SwiftUI

struct ScrollContentView: View {
    @Bindable var workout: Workout
    @Binding var exercises: [WorkoutExercise]
    var focused: FocusState<Bool>.Binding
    @Binding var dragging: Bool
    @State private var selectedExercise: WorkoutExercise?
    @State private var selectedExerciseScale: CGFloat = 1.0
    @State private var selectedExerciseFrame: CGRect = .zero
    @State private var offset: CGSize = .zero
    @State private var hapticsTrigger: Bool = false
    @State private var initialScrollOffset: CGRect = .zero
    @State private var scrolledExercise: WorkoutExercise.ID?
    @State private var currentScrollId: UUID?
    @State private var scrollTimer: Timer?
    @State private var topRegion: CGRect = .zero
    @State private var bottomRegion: CGRect = .zero
    @State private var lastActiveScrollId: UUID?
    @State private var parentFrame: CGRect = .zero
    let minimizing: Bool
    var sortedExercises: [WorkoutExercise] {
        exercises.sorted { $0.order < $1.order }
    }
    var body: some View {
        ZStack {
            ScrollView {
                LazyVStack {
                    WorkoutInfoView(workout: workout, focused: focused)
                        .padding(.top, -50)
                    ForEach(sortedExercises) { exercise in
                        ExerciseCardView(
                            workout: workout,
                            workoutExercise: exercise,
                            focused: focused,
                            moving: dragging,
                            selectedExercise: $selectedExercise,
                            selectedExerciseScale: $selectedExerciseScale,
                            selectedExerciseFrame: $selectedExerciseFrame,
                            offset: $offset,
                            hapticsTrigger: $hapticsTrigger,
                            initialScrollOffset: $initialScrollOffset,
                            lastActiveScrollId: $lastActiveScrollId,
                            dragging: $dragging,
                            minimizing: minimizing,
                            onScroll: checkAndScroll,
                            onSwap: checkAndSwapItems
                        )
                        .opacity(selectedExercise?.id == exercise.id ? 0 : 1)
                        .onGeometryChange(for: CGRect.self) {
                            $0.frame(in: .global)
                        } action: { newValue in
                            if !minimizing{
                                if selectedExercise?.id == exercise.id {
                                    selectedExerciseFrame = newValue
                                }
                                exercise.frame = Frame(newValue)
                            }
                        }
                    }
                }
                .scrollTargetLayout()
            }
            .scrollIndicators(.hidden)
            .scrollPosition(id: $scrolledExercise)
            .contentMargins(.vertical, 50)
            .scrollTargetBehavior(.viewAligned)
            .padding(.horizontal, 20)
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
                        moving: dragging,
                        selectedExercise: $selectedExercise,
                        selectedExerciseScale: $selectedExerciseScale,
                        selectedExerciseFrame: $selectedExerciseFrame,
                        offset: $offset,
                        hapticsTrigger: $hapticsTrigger,
                        initialScrollOffset: $initialScrollOffset,
                        lastActiveScrollId: $lastActiveScrollId,
                        dragging: $dragging,
                        minimizing: minimizing,
                        onScroll: checkAndScroll,
                        onSwap: checkAndSwapItems
                    )
                    .frame(
                        width: selectedExercise.frame.asCGRect().width,
                        height: selectedExercise.frame.asCGRect().height
                    )
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
    
    func checkAndScroll(_ location: CGPoint) {
            let topStatus = topRegion.contains(location)
            let bottomStatus = bottomRegion.contains(location)
            
            if topStatus || bottomStatus {
                guard scrollTimer == nil else { return }
                
                scrollTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                    if let currentIndex = sortedExercises.firstIndex(where: { $0.id == lastActiveScrollId }) {
                        var nextIndex = currentIndex
                        
                        if topStatus {
                            nextIndex = max(currentIndex - 1, 0)
                        } else {
                            nextIndex = min(currentIndex + 1, sortedExercises.count - 1)
                        }
                        
                        lastActiveScrollId = sortedExercises[nextIndex].id
                        withAnimation {
                            scrolledExercise = lastActiveScrollId
                        }
                    }
                }
            } else {
                scrollTimer?.invalidate()
                scrollTimer = nil
            }
        }
    private func checkAndSwapItems(_ location: CGPoint) {
        guard let currentExercise = exercises.first(where: { $0.id == selectedExercise?.id }),
              let fallingExercise = exercises.first(where: {
                  $0.id != currentExercise.id &&
                  $0.frame.asCGRect().contains(location)
              }) else { return }
        // Get the current indices
        let currentIndex = currentExercise.order
        let fallingIndex = fallingExercise.order
        
        // Only proceed if indices are different
        guard currentIndex != fallingIndex else { return }
        hapticsTrigger.toggle()
        withAnimation(.snappy(duration: 0.25, extraBounce: 0)) {
            currentExercise.order = fallingIndex
            fallingExercise.order = currentIndex
        }
    }
}
#Preview {
    let preview = PreviewContainer.preview
    let workout = preview.workout
    ScrollContentView(workout: workout, exercises: .constant(workout.exercises), focused: FocusState<Bool>().projectedValue, dragging: .constant(false), minimizing: true)
        .modelContainer(preview.container)
}
