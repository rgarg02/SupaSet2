//
//  ExerciseCardView.swift
//  SupaSet
//
//  Created by Rishi Garg on 11/7/24.
//

import SwiftUI
import SwiftData

struct ExerciseCardView: View {
    let exercise: WorkoutExercise
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var dragState: DragState
    private let columns = [
        GridItem(.fixed(40)),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.fixed(80))
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ExerciseTopControls(exercise: exercise, dragging: $dragState.isDragging)
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                .gesture(dragGesture)
            
            if !dragState.isDragging {
                exerciseSetsView
            }
        }
        .padding(.vertical)
    }
    
    private var exerciseSetsView: some View {
        VStack(spacing: 8) {
            SetColumnNamesView(exerciseID: exercise.exerciseID, isTemplate: false)
                .onChange(of: exercise.exerciseID) { _, _ in
                    updateActivityIfNeeded()
                }
            
            ForEach(exercise.sortedSets, id: \.self) { set in
                @Bindable var set = set
                setRow(for: set)
            }
            
            addSetButton
        }
    }
    
    private func setRow(for set: ExerciseSet) -> some View {
        @Bindable var set = set
        // count working sets
        let workingSetOrder = exercise.sortedSets
                .prefix(while: { $0.order < set.order })
                .filter { $0.type == .working }
                .count
        return SwipeAction(cornerRadius: 8, direction: .trailing) {
            SetRowViewCombined(
                order: workingSetOrder,
                isTemplate: false,
                weight: $set.weight,
                reps: $set.reps,
                isDone: $set.isDone, type: $set.type
            )
            .onChange(of: set.weight) { _, _ in updateActivityIfNeeded() }
            .onChange(of: set.reps) { _, _ in updateActivityIfNeeded() }
            .onChange(of: set.isDone) { _, _ in updateActivityIfNeeded() }
        } actions: {
            Action(tint: .red, icon: "trash.fill") {
                withAnimation(.easeInOut) {
                    updateActivityIfNeeded()
                    exercise.deleteSet(set)
                    modelContext.delete(set)
                }
            }
        }
    }
    
    private var addSetButton: some View {
        PlaceholderSetRowView(templateSet: false)
            .onTapGesture {
                withAnimation(.snappy(duration: 0.25)) {
                    exercise.insertSet(
                        reps: exercise.sortedSets.last?.reps ?? 0,
                        weight: exercise.sortedSets.last?.weight ?? 0
                    )
                }
                updateActivityIfNeeded()
            }
    }
    
    private var dragGesture: some Gesture {
        LongPressGesture(minimumDuration: 0.25)
            .sequenced(before: DragGesture(minimumDistance: 0, coordinateSpace: .global))
            .onChanged { value in
                switch value {
                case .second(let status, let dragValue):
                    if status {
                        if dragState.selectedExercise == nil {
                            dragState.startDrag(
                                item: exercise,
                                initialFrame: dragState.itemFrames[exercise.id] ?? .zero
                            )
                            dragState.hapticFeedback.toggle()
                        }
                        
                        if let dragValue {
                            dragState.updateDrag(
                                translation: dragValue.translation,
                                location: dragValue.location
                            )
                            
                            // Use new scroll function
                            dragState.checkAndScroll(dragValue.location)
                            checkAndSwapItems(at: dragValue.location)
                        }
                    }
                default: break
                }
            }
            .onEnded { _ in
                dragState.endDrag()
            }
    }
    
    func checkAndSwapItems(at location: CGPoint) {
        guard let selectedExercise = dragState.selectedExercise as? WorkoutExercise,
              let workout = exercise.workout else { return }
        
        let sortedExercises = workout.exercises.sorted(by: { $0.order < $1.order })
        guard let draggedIndex = sortedExercises.firstIndex(where: { $0.id == selectedExercise.id }) else { return }
        
        for (index, exercise) in sortedExercises.enumerated() {
            if index != draggedIndex,
               let frame = dragState.itemFrames[exercise.id],
               frame.contains(location) {
                withAnimation(.snappy(duration: 0.2)) {
                    let tempOrder = exercise.order
                    exercise.order = selectedExercise.order
                    selectedExercise.order = tempOrder
                    dragState.hapticFeedback.toggle()
                }
                break
            }
        }
    }
    
    private func updateActivityIfNeeded() {
        if let workout = exercise.workout {
            WorkoutActivityManager.shared.updateWorkoutActivity(workout: workout)
        }
    }
}

#Preview {
    @Previewable @StateObject var dragState = DragState()
    let preview = PreviewContainer.preview
    let workout = preview.workout
    let exercise = workout.exercises.first!
    ExerciseCardView(exercise: exercise)
        .environmentObject(dragState)
        .modelContainer(preview.container)
        .environment(preview.viewModel)
}
