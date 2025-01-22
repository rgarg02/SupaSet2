import SwiftUI

// First, create a protocol that both exercise types will conform to
protocol ExerciseMenuType {
    var exerciseID: String { get }
    // Add any other common properties needed
}

// Make both types conform to the protocol
extension WorkoutExercise: ExerciseMenuType {}
extension TemplateExercise: ExerciseMenuType {}

struct ExerciseTopControls<T: ExerciseMenuType>: View {
    let exercise: T
    @Environment(ExerciseViewModel.self) var viewModel
    @State private var showMenuOptions = false
    @Binding var dragging: Bool
    var body: some View {
        VStack{
            HStack {
                Text(viewModel.getExerciseName(for: exercise.exerciseID))
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.theme.accent)
                Spacer()
                if !dragging{
                    Button(action: {
                        withAnimation(.snappy) {
                            showMenuOptions.toggle()
                        }
                    }) {
                        Image(systemName: "ellipsis")
                            .foregroundColor(.theme.accent)
                    }
                    .sheet(isPresented: $showMenuOptions) {
                        NavigationView{
                            ExerciseMenu(exercise: exercise)
                                .foregroundColor(.theme.text)
                        }
                        .presentationDetents([.fraction(0.5)])
                        .ignoresSafeArea()
                        .presentationDragIndicator(.hidden)
                    }
                }
            }
            if !dragging{
                ExerciseNotesView(exerciseID: exercise.exerciseID)
            }
        }
    }
}

// Preview Providers
#Preview("Exercise Top Controls") {
    let preview = PreviewContainer.preview
    ExerciseTopControls(exercise: preview.workout.sortedExercises[0], dragging: .constant(false))
        .padding()
        .modelContainer(preview.container)
        .environment(preview.viewModel)
}
