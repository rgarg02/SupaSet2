//
//  TemplateExerciseCard.swift
//  SupaSet
//
//  Created by Rishi Garg on 1/21/25.
//

import SwiftUI

struct TemplateExerciseCard: View {
    @Bindable var templateExericse: TemplateExercise
    @Environment(ExerciseViewModel.self) var viewModel
    @Environment(\.modelContext) var modelContext
    // New bindings for gesture handling
    @Binding var selectedExercise: TemplateExercise?
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
            GridItem(.flexible()) // Flexible for reps
    ]
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ExerciseTopControls(exercise: templateExericse, dragging: $dragging)
            .frame(maxWidth: .infinity)
            .gesture(
                DraggableGestureHandler(item: templateExericse, selectedExercise: $selectedExercise, selectedExerciseScale: $selectedExerciseScale, selectedExerciseFrame: $selectedExerciseFrame, offset: $offset, hapticsTrigger: $hapticsTrigger, initialScrollOffset: $initialScrollOffset, lastActiveScrollId: $lastActiveScrollId, dragging: $dragging, parentBounds: $parentBounds, exerciseFrames: $exerciseFrames, onScroll: onScroll, onSwap: onSwap)
                    .gesture
            )
            if !dragging{
                VStack(spacing: 8) {
                    ScrollView(.vertical){
                        SetColumnNamesView(exerciseID: templateExericse.exerciseID, isTemplate: true)
                        ForEach(templateExericse.sortedSets, id: \.self) { set in
                            @Bindable var set = set
                            SwipeAction(cornerRadius: 8, direction: .trailing){
                                SetRowViewCombined(order: set.order, isTemplate: true, weight: $set.weight, reps: $set.reps, isDone: .constant(false))

                            } actions:{
                                Action(tint: .red, icon: "trash.fill") {
                                    withAnimation(.easeInOut){
                                        templateExericse.deleteSet(set)
                                        modelContext.delete(set)
                                    }
                                }
                            }
                        }
                        PlaceholderSetRowView(templateSet: true)
                            .onTapGesture {
                                withAnimation(.snappy(duration: 0.25)) {
                                    templateExericse.insertSet(reps: templateExericse.sortedSets.last?.reps ?? 0)
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

//#Preview("Template Exercise Card") {
//    let preview = PreviewContainer.preview
//    TemplateExerciseCard(templateExericse: preview.template.exercises[0])
//        .padding()
//        .modelContainer(preview.container)
//        .environment(preview.viewModel)
//}
