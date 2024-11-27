import SwiftUI
import UniformTypeIdentifiers
import SwiftData
struct WorkoutScrollContent: View {
    @Bindable var workout: Workout
    @Binding var scrolledExercise: Int?
    var focused: FocusState<Bool>.Binding
    @Binding var dragging : Bool
    let minimizing: Bool
    var body: some View {
        ScrollContentView(workout: workout, exercises: $workout.exercises, focused: focused, dragging: $dragging, minimizing: minimizing)
        .background(Color.theme.background)
    }
}
#Preview {
    let preview = PreviewContainer.preview
    WorkoutScrollContent(
        workout: preview.workout,
        scrolledExercise: .constant(0),
        focused: FocusState<Bool>().projectedValue,
        dragging: .constant(false), minimizing: true
    )
    .modelContainer(preview.container)
}
