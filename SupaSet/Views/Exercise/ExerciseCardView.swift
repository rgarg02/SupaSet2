//
//  ExerciseCardView.swift
//  SupaSet
//
//  Created by Rishi Garg on 11/7/24.
//

import SwiftUI
import SwiftData

struct ExerciseCardView: View {
    let workoutExercise: WorkoutExercise
    @Environment(\.modelContext) private var modelContext
    @State private var offsets = [CGSize](repeating: CGSize.zero, count: 6)
    // New bindings for gesture handling
    @Binding var selectedExercise: WorkoutExercise?
    @Binding var selectedExerciseScale: CGFloat
    @Binding var selectedExerciseFrame: CGRect
    @Binding var offset: CGSize
    @Binding var hapticsTrigger: Bool
    @Binding var initialScrollOffset: CGRect
    @Binding var lastActiveScrollId: UUID?
    @Binding var dragging: Bool
    @Binding var parentBounds: CGRect
    @Binding var exerciseFrames: [UUID: CGRect]
    let onScroll: (CGPoint) -> Void
    let onSwap: (CGPoint) -> Void
    private let columns = [
        GridItem(.fixed(40)), // Smaller column for set number
        GridItem(.flexible()), // Flexible for weight
        GridItem(.flexible()), // Flexible for reps
        GridItem(.fixed(80))  // Smaller column for checkbox
    ]
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ExerciseTopControls(exercise: workoutExercise, dragging: $dragging)
                .frame(maxWidth: .infinity)
                .gesture(
                    DraggableGestureHandler(item: workoutExercise, selectedExercise: $selectedExercise, selectedExerciseScale: $selectedExerciseScale, selectedExerciseFrame: $selectedExerciseFrame, offset: $offset, hapticsTrigger: $hapticsTrigger, initialScrollOffset: $initialScrollOffset, lastActiveScrollId: $lastActiveScrollId, dragging: $dragging, parentBounds: $parentBounds, exerciseFrames: $exerciseFrames, onScroll: onScroll, onSwap: onSwap)
                        .gesture
                )
            if !dragging{
                VStack(spacing: 8) {
                    ScrollView(.vertical){
                        SetColumnNamesView(exerciseID: workoutExercise.exerciseID, isTemplate: false)
                        ForEach(workoutExercise.sortedSets, id: \.self) { set in
                            @Bindable var set = set
                            SwipeAction(cornerRadius: 8, direction: .trailing){
                                SetRowViewCombined(order: set.order, isTemplate: false, weight: $set.weight, reps: $set.reps, isDone: $set.isDone)
                            } actions:{
                                Action(tint: .red, icon: "trash.fill") {
                                    withAnimation(.easeInOut){
                                        workoutExercise.deleteSet(set)
                                        modelContext.delete(set)
                                    }
                                }
                            }
                        }
                        PlaceholderSetRowView(templateSet: false)
                            .onTapGesture {
                                withAnimation(.snappy(duration: 0.25)) {
                                    workoutExercise.insertSet(reps: workoutExercise.sortedSets.last?.reps ?? 0, weight: workoutExercise.sortedSets.last?.weight ?? 0)
                                }
                            }
                    }
                }
                .frame(minHeight: 240)
                Spacer()
            }
        }
        .padding(.vertical)
    }
}

#Preview {
    let preview = PreviewContainer.preview
    let workout = preview.workout
    let exercise = workout.exercises.first!
    ExerciseCardView(
        workoutExercise: exercise,
        selectedExercise: .constant(nil),
        selectedExerciseScale: .constant(1.0),
        selectedExerciseFrame: .constant(.zero),
        offset: .constant(.zero),
        hapticsTrigger: .constant(false),
        initialScrollOffset: .constant(.zero),
        lastActiveScrollId: .constant(nil),
        dragging: .constant(false),
        parentBounds: .constant(.zero),
        exerciseFrames: .constant([:]),
        onScroll: { _ in },
        onSwap: { _ in }
    )
    .modelContainer(preview.container)
    .environment(preview.viewModel)
}
