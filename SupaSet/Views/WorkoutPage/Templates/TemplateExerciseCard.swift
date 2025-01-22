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
            GridItem(.flexible()), // Flexible for reps
            GridItem(.fixed(80))  // Smaller column for checkbox
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
                        LazyVGrid(columns: columns) {
                            Text("SET")
                                .font(.caption)
                                .foregroundColor(.theme.text)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                            //                    .frame(width: 20)
                            
                            Text("REPS")
                                .font(.caption)
                                .foregroundColor(.theme.text)
                                .frame(maxWidth: .infinity, alignment: .center)
                            //                    .frame(width: 100)
                            
                            Text("DONE")
                                .font(.caption)
                                .foregroundColor(.theme.text)
                                .frame(maxWidth: .infinity, alignment: .center)
                            //                    .frame(width: 40)
                        }
                        ForEach(templateExericse.sortedSets, id: \.self) { set in
                            SwipeAction(cornerRadius: 8, direction: .trailing){
                                LazyVGrid(columns: columns) {
                                    Text("SET")
                                        .font(.caption)
                                        .foregroundColor(.theme.text)
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                    //                    .frame(width: 20)
                                    
                                    Text("WEIGHT")
                                        .font(.caption)
                                        .foregroundColor(.theme.text)
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                    //                    .frame(width: 100)
                                    
                                    Text("REPS")
                                        .font(.caption)
                                        .foregroundColor(.theme.text)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                    //                    .frame(width: 100)
                                    
                                    Text("DONE")
                                        .font(.caption)
                                        .foregroundColor(.theme.text)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                    //                    .frame(width: 40)
                                }

                            } actions:{
//                                Action(tint: .red, icon: "trash.fill") {
//                                    withAnimation(.easeInOut){
//                                        workoutExercise.deleteSet(set)
//                                        modelContext.delete(set)
//                                    }
//                                }
                            }
                        }
                        PlaceholderSetRowView()
//                            .onTapGesture {
//                                withAnimation(.snappy(duration: 0.25)) {
//                                    workoutExercise.insertSet(reps: workoutExercise.sortedSets.last?.reps ?? 0, weight: workoutExercise.sortedSets.last?.weight ?? 0)
//                                }
//                            }
                    }
                }
                .frame(minHeight: 240)
                Spacer()
            }
        }
        .modifier(ExerciseCardStyle())
    }
}

//#Preview("Template Exercise Card") {
//    let preview = PreviewContainer.preview
//    TemplateExerciseCard(templateExericse: preview.template.exercises[0])
//        .padding()
//        .modelContainer(preview.container)
//        .environment(preview.viewModel)
//}
