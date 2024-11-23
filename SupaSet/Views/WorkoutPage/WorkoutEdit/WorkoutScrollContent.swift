import SwiftUI

struct WorkoutScrollContent: View {
    @Bindable var workout: Workout
    @Binding var scrolledExercise: Int?
    @State private var reorderExercises: Bool = false
    @State private var heldExerciseID: UUID? = nil
    var focused: FocusState<Bool>.Binding
    var scrollOffset: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            if reorderExercises {
                VStack{
                    WorkoutInfoView(workout: workout, focused: focused, reorderExercises: $reorderExercises)
                    List {
                        ForEach(workout.sortedExercises) { exercise in
                            Text(exercise.exercise.name)
                        }
                        .onMove { from, to in
                            workout.moveExercise(from: from, to: to)
                        }
                        .onDelete { indexSet in
                            workout.deleteExercise(at: indexSet)
                        }
                    }
                    .listStyle(.plain)
                    .environment(\.editMode, .constant(.active))
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
                                .onLongPressGesture(minimumDuration: 0.5) {
                                    heldExerciseID = exercise.id
                                    reorderExercises = true
                                }
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
        .onChange(of: reorderExercises) { oldValue, newValue in
            if !newValue {
                heldExerciseID = nil
            }
        }
    }
}

#Preview {
    let preview = PreviewContainer.preview
    WorkoutScrollContent(
        workout: preview.workout,
        scrolledExercise: .constant(0),
        focused: FocusState<Bool>().projectedValue,
        scrollOffset: 140
    )
    .modelContainer(preview.container)
}
