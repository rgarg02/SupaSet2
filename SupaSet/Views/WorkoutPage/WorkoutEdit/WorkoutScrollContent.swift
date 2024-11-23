import SwiftUI

struct WorkoutScrollContent: View {
    @Bindable var workout: Workout
    @Binding var scrolledExercise: Int?
    @Binding var reorderExercises: Bool
    var focused: FocusState<Bool>.Binding
    var scrollOffset: CGFloat
    var body: some View {
        GeometryReader { geometry in
            if reorderExercises {
                VStack{
                    WorkoutInfoView(workout: workout, focused: focused, reorderExercises: $reorderExercises)
                    List {
                        ForEach(workout.sortedExercises) { exercise in
                            ExerciseListRow(exercise: exercise)
                                .listRowBackground(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.theme.background)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .strokeBorder(Color.theme.accent.opacity(0.3), lineWidth: 2)
                                        )
                                        .shadow(color: Color.theme.accent.opacity(0.1), radius: 4, x: 0, y: 2)
                                )
                        }
                        .onMove { from, to in
                            workout.moveExercise(from: from, to: to)
                        }
                        .onDelete { indexSet in
                            withAnimation(.smooth){
                                workout.deleteExercise(at: indexSet)
                            }
                        }
                        .listRowSeparator(.hidden)
                        
                    }
                    .scrollIndicators(.hidden)
                    .frame(maxHeight: .infinity)
                    .listRowSpacing(10)
                    .environment(\.editMode, .constant(.active))
                    .listStyle(.plain)
                }
                .padding(.horizontal, 20)
                
            } else {
                ScrollView {
                    LazyVStack{
                        WorkoutInfoView(workout: workout, focused: focused, reorderExercises: $reorderExercises)
                            .padding(.top, -50)
                        
                        ForEach(workout.sortedExercises) { exercise in
                            
                            ExerciseCardView(workout: workout, workoutExercise: exercise, focused: focused)
                                .containerRelativeFrame(.vertical, count: 1, spacing: 20)
                                .scrollTransition { content, phase in
                                    content
                                        .opacity(phase.isIdentity ? 1 : 0.8)
                                        .scaleEffect(phase.isIdentity ? 1 : 0.9)
                                }
                                .id(exercise.order)
                        }
                    }
                    .scrollTargetLayout()
                    .scrollOffsetTracking(scrollOffset: scrollOffset)
                }
                .padding(.horizontal, 20)
                .contentMargins(.vertical, 50)
                .scrollTargetBehavior(.viewAligned)
                .overlay(alignment: .trailing) {
                    WorkoutProgressDots(
                        totalExercises: workout.sortedExercises.count,
                        currentExerciseIndex: scrolledExercise ?? 0
                    )
                    .padding(.trailing, 5)
                }
                .scrollIndicators(.hidden)
                .scrollPosition(id: $scrolledExercise)
            }
        }
        .background(Color.theme.background)
    }
}

#Preview {
    let preview = PreviewContainer.preview
    WorkoutScrollContent(
        workout: preview.workout,
        scrolledExercise: .constant(0), reorderExercises: .constant(false),
        focused: FocusState<Bool>().projectedValue,
        scrollOffset: 140
    )
    .modelContainer(preview.container)
}
