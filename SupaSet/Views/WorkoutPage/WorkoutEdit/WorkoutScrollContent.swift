import SwiftUI
import UniformTypeIdentifiers
import SwiftData
struct WorkoutScrollContent: View {
    @Bindable var workout: Workout
    @Binding var scrolledExercise: Int?
    var focused: FocusState<Bool>.Binding
    @State var scrollOffset: CGFloat = 0
    @Binding var moving : Bool
    var body: some View {
        ScrollContentView(workout: workout, exercises: $workout.exercises, focused: focused, moving: $moving, scrollOffset: $scrollOffset)
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
