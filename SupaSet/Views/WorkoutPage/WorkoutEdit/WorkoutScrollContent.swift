import SwiftUI
import UniformTypeIdentifiers
import SwiftData
struct WorkoutScrollContent: View {
    @Bindable var workout: Workout
    @Binding var scrolledExercise: Int?
    var focused: FocusState<Bool>.Binding
    var scrollOffset: CGFloat
    @State private var dragging: WorkoutExercise?
    @Binding var moving : Bool
    @State private var haptics: Bool = false
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                LazyVStack{
                    WorkoutInfoView(workout: workout, focused: focused, moving: $moving)
                        .padding(.top, -50)
                    
                    ForEach(workout.sortedExercises) { exercise in
                        
                        ExerciseCardView(workout: workout, workoutExercise: exercise,moving: moving, focused: focused)
                            .opacity(dragging == exercise ? 0 : 1)
                            .if(!moving) { view in
                                    view.containerRelativeFrame(.vertical, count: 1, spacing: 20)
                                }
                            .scrollTransition { content, phase in
                                content
                                    .opacity(phase.isIdentity ? 1 : 0.8)
                                    .scaleEffect(phase.isIdentity ? 1 : 0.9)
                            }
        
                            .onDrag({
                                return NSItemProvider(object: exercise.id.uuidString as NSString)
                            }, preview: {
                                ExerciseCardView(workout: workout, workoutExercise: exercise, moving: true, focused: focused)
                                    .safeAreaPadding(.bottom)
                                    .onAppear {
                                        moving = true
                                        dragging = exercise
                                    }
                            })
                            .onDrop(of: [UTType.exerciseTransfer], delegate: DropExerciseDelegate(
                                    moving: $moving,
                                    dragging: $dragging,
                                    exercise: exercise,
                                    workout: workout,
                                    haptics: $haptics
                                ))
                            .id(exercise.order)
                    }
                }
                .scrollTargetLayout()
                .scrollOffsetTracking(scrollOffset: scrollOffset)
            }
            .sensoryFeedback(.impact, trigger: haptics)
            .onDrop(of: [UTType.exerciseTransfer], delegate: DropOutsideDelegate(dragging: $dragging, moving: $moving))
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
        .background(Color.theme.background)
    }
}
#Preview {
    let preview = PreviewContainer.preview
    WorkoutScrollContent(
        workout: preview.workout,
        scrolledExercise: .constant(0),
        focused: FocusState<Bool>().projectedValue,
        scrollOffset: 140,
        moving: .constant(false)
    )
    .modelContainer(preview.container)
}
