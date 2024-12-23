import SwiftUI
import UniformTypeIdentifiers
import SwiftData
struct WorkoutScrollContent: View {
    @Bindable var workout: Workout
    @Binding var dragging : Bool
    let minimizing: Bool
    var body: some View {
        NavigationView{
            ScrollContentView(workout: workout, exercises: $workout.exercises, dragging: $dragging, minimizing: minimizing)
                .background(Color.theme.background)
                .dismissKeyboardOnTap()
        }
    }
}
#Preview {
    let preview = PreviewContainer.preview
    WorkoutScrollContent(
        workout: preview.workout,
        dragging: .constant(false), minimizing: true
    )
    .modelContainer(preview.container)
}
