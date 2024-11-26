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
    @Binding var moving: Bool
    @State var dragging: Bool = false
    @Binding var scrollOffset: CGFloat
    @State private var selectedExercise: WorkoutExercise?
    @State private var selectedExerciseScale: CGFloat = 1.0
    @State private var selectedExerciseFrame: CGRect = .zero
    @State private var offset: CGSize = .zero
    @State private var hapticsTrigger: Bool = false
    @State private var initialScrollOffset: CGRect = .zero
    @State private var scrolledExercise: Int?
    private let contentMargins: CGFloat = 30
    var sortedExercises: [WorkoutExercise] {
        exercises.sorted { $0.order < $1.order }
    }
    
    var body: some View {
        ScrollView {
            LazyVStack {
                WorkoutInfoView(workout: workout, focused: focused)
                    .padding(.top, -50)
                ForEach(sortedExercises) { exercise in
                    ExerciseCardView(workout: workout,
                                     workoutExercise: exercise,
                                     focused: focused,
                                     moving: dragging)
                    .if(!dragging, transform: { view in
                        view
                            .containerRelativeFrame(.vertical, count: 1, spacing: 0)
                    })
                    .opacity(selectedExercise?.id == exercise.id ? 0 : 1)
                    .onGeometryChange(for: CGRect.self) {
                        $0.frame(in: .global)
                    } action: { newValue in
                        if selectedExercise?.id == exercise.id {
                            selectedExerciseFrame = newValue
                        }
                        exercise.frame = Frame(newValue)
                    }
                    .gesture(customCombinedGesture(exercise))
                }
            }
            .scrollTargetLayout()
        }
        .scrollIndicators(.hidden)
        .scrollPosition(id: $scrolledExercise)
        .contentMargins(.vertical, 50)
        .scrollTargetBehavior(.viewAligned)
        .padding(.horizontal, 20)
        .overlay(alignment: .trailing) {
            WorkoutProgressDots(
                totalExercises: workout.sortedExercises.count,
                currentExerciseIndex: scrolledExercise ?? 0
            )
            .padding(.trailing, 10)
        }
        .overlay(alignment: .topLeading) {
            if let selectedExercise {
                ExerciseCardView(workout: workout,
                                 workoutExercise: selectedExercise,
                                 focused: focused,
                                 moving: dragging)
                .frame(
                    width: selectedExercise.frame.asCGRect().width,
                    height: selectedExercise.frame.asCGRect().height
                )
                .scaleEffect(selectedExerciseScale)
                .offset(x: initialScrollOffset.minX,
                        y: initialScrollOffset.minY)
                .offset(offset)
                .ignoresSafeArea()
                .transition(.identity)
            }
        }
        .sensoryFeedback(.impact, trigger: hapticsTrigger)
    }
    
    func customCombinedGesture(_ exercise: WorkoutExercise) -> some Gesture {
        LongPressGesture(minimumDuration: 0.25)
            .sequenced(before: DragGesture(minimumDistance: 0, coordinateSpace: .global))
            .onChanged { value in
                switch value {
                case .second(let status, let value):
                    if status {
                        if selectedExercise == nil {
                            selectedExercise = exercise
                            selectedExerciseFrame = exercise.frame.asCGRect()
                            initialScrollOffset = selectedExerciseFrame
                            hapticsTrigger.toggle()
                            
                            withAnimation(.smooth(duration: 0.2, extraBounce: 0)) {
                                selectedExerciseScale = 1.1
                                dragging = true
                            }
                        }
                        
                        if let value {
                            offset = value.translation
                            let location = value.location
                            checkAndSwapItems(location)
                        }
                    }
                default: ()
                }
            }
            .onEnded { _ in
                withAnimation(.snappy(duration: 0.25, extraBounce: 0),
                              completionCriteria: .logicallyComplete) {
                    selectedExercise?.frame = Frame(selectedExerciseFrame)
                    initialScrollOffset = selectedExerciseFrame
                    selectedExerciseScale = 1.0
                    offset = .zero
                } completion: {
                    dragging = false
                    selectedExercise = nil
                    initialScrollOffset = .zero
                    selectedExerciseFrame = .zero
                }
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
    ScrollContentView(workout: workout, exercises: .constant(workout.exercises), focused: FocusState<Bool>().projectedValue, moving: .constant(false), scrollOffset: .constant(0))
        .modelContainer(preview.container)
}
