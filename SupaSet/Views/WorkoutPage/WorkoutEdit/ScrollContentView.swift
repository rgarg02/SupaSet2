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
    @State private var exerciseFrames: [UUID: CGRect] = [:]
    let minimizing: Bool
    var sortedExercises: [WorkoutExercise] {
        exercises.sorted { $0.order < $1.order }
    }
    var body: some View {
        ZStack {
            ScrollView {
                LazyVStack {
                    WorkoutInfoView(workout: workout, focused: focused)
                        .padding(.top, -30)
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
                            if !minimizing{
                                if selectedExercise?.id == exercise.id {
                                    selectedExerciseFrame = newValue
                                }
                                exerciseFrames[exercise.id] = newValue
//                                exercise.frame = Frame(newValue)
                            }
                        }
                    }
                }
                .padding(.bottom, 50)
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
//                    .frame(
//                        width: selectedExercise.frame?.asCGRect().width ?? .zero,
//                        height: selectedExercise.frame?.asCGRect().height ?? .zero
//                    )
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
    
    func checkAndScroll(_ location: CGPoint) {
        // Calculate centered x position (middle of the parent frame)
        let centeredLocation = CGPoint(
            x: parentFrame.midX,
            y: location.y
        )
        
        let topStatus = topRegion.contains(centeredLocation)
        let bottomStatus = bottomRegion.contains(centeredLocation)
        
        // Cancel existing timer if we're not in scroll regions
        if !topStatus && !bottomStatus {
            scrollTimer?.invalidate()
            scrollTimer = nil
            return
        }
        
        // Don't create new timer if one exists
        guard scrollTimer == nil else { return }
        
        // Create new timer with more frequent updates
        scrollTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            guard let currentIndex = sortedExercises.firstIndex(where: { $0.id == selectedExercise?.id }) else { return }
            
            var nextIndex = currentIndex
            
            if topStatus {
                nextIndex = max(currentIndex - 1, 0)
            } else {
                nextIndex = min(currentIndex + 1, sortedExercises.count - 1)
            }
            
            // Only scroll if we can actually move
            guard nextIndex != currentIndex else {
                scrollTimer?.invalidate()
                scrollTimer = nil
                return
            }
            
            lastActiveScrollId = sortedExercises[nextIndex].id
            withAnimation(.smooth(duration: 0.1)) {
                scrolledExercise = lastActiveScrollId
            }
        }
    }
    private func checkAndSwapItems(_ location: CGPoint) {
        guard let currentExercise = exercises.first(where: { $0.id == selectedExercise?.id }) else { return }
        
        // Create centered point for checking
        let centeredLocation = CGPoint(
            x: parentFrame.midX,
            y: location.y
        )
        
        // Find exercise that contains the centered y-coordinate
        let fallingExercise = exercises.first { exercise in
            guard exercise.id != currentExercise.id else { return false }
            let frame = exerciseFrames[exercise.id] ?? .zero
//            let frame = exercise.frame?.asCGRect() ?? .zero
            return centeredLocation.y >= frame.minY && centeredLocation.y <= frame.maxY
        }
        
        guard let fallingExercise = fallingExercise else { return }
        
        let currentIndex = currentExercise.order
        let fallingIndex = fallingExercise.order
        
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
