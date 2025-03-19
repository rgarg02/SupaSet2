// TemplateExerciseCard.swift
import SwiftUI

struct TemplateExerciseCard: View {
    @Bindable var templateExercise: TemplateExercise
    @Environment(ExerciseViewModel.self) var viewModel
    @Environment(\.modelContext) var modelContext
    @EnvironmentObject var dragState: DragState
    
    private let columns = [
        GridItem(.fixed(40)),   // Smaller column for set number
        GridItem(.flexible()),  // Flexible for weight
        GridItem(.flexible())   // Flexible for reps
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ExerciseTopControls(exercise: templateExercise, dragging: $dragState.isDragging)
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
        return VStack(spacing: 8) {
            ScrollView(.vertical) {
                SetColumnNamesView(exerciseID: templateExercise.exerciseID, isTemplate: true)
                
                ForEach(templateExercise.sortedSets, id: \.self) { set in
                    @Bindable var set = set
                    setRow(for: set)
                }
                
                addSetButton
            }
        }
        .frame(minHeight: 240)
    }
    
    private func setRow(for set: TemplateExerciseSet) -> some View {
        @Bindable var set = set
        return SwipeAction(cornerRadius: 8, direction: .trailing) {
            SetRowViewCombined(
                order: set.order,
                isTemplate: true,
                weight: $set.weight,
                reps: $set.reps,
                isDone: .constant(false), type: $set.type
            )
        } actions: {
            Action(tint: .red, icon: "trash.fill") {
                withAnimation(.easeInOut) {
                    templateExercise.deleteSet(set)
                    modelContext.delete(set)
                }
            }
        }
    }
    
    private var addSetButton: some View {
        PlaceholderSetRowView(templateSet: true)
            .onTapGesture {
                withAnimation(.snappy(duration: 0.25)) {
                    templateExercise.insertSet(reps: templateExercise.sortedSets.last?.reps ?? 0)
                }
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
                                item: templateExercise,
                                initialFrame: dragState.itemFrames[templateExercise.id] ?? .zero
                            )
                            dragState.hapticFeedback.toggle()
                        }
                        
                        if let dragValue {
                            dragState.updateDrag(
                                translation: dragValue.translation,
                                location: dragValue.location
                            )
                            
                            // Let DragState handle scrolling
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
        guard let selectedExercise = dragState.selectedExercise as? TemplateExercise,
              let draggedIndex = templateExercise.template?.exercises.sorted(by: { $0.order < $1.order }).firstIndex(where: { $0.id == selectedExercise.id }) else { return }
        
        if let template = templateExercise.template {
            for (index, exercise) in template.exercises.sorted(by: { $0.order < $1.order }).enumerated() {
                if index != draggedIndex,
                   let frame = dragState.itemFrames[exercise.id],
                   frame.contains(location) {
                    withAnimation(.smooth(duration: 0.2)) {
                        let tempOrder = exercise.order
                        exercise.order = selectedExercise.order
                        selectedExercise.order = tempOrder
                        dragState.hapticFeedback.toggle()
                    }
                    break
                }
            }
        }
    }
}
