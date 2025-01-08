import SwiftUI

struct ExerciseTopControls: View {
    let workoutExercise: WorkoutExercise
    @Environment(ExerciseViewModel.self) var viewModel
    @State private var showMenuOptions = false
    @Binding var dragging: Bool
    var body: some View {
        VStack{
            HStack {
                Text(viewModel.getExerciseName(for: workoutExercise.exerciseID))
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.theme.text)
                Spacer()
                if !dragging {
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
                            ExerciseMenu(workoutExercise: workoutExercise)
                                .foregroundColor(.theme.text)
                        }
                        .presentationDetents([.fraction(0.5)])
                        .ignoresSafeArea()
                        .presentationDragIndicator(.hidden)
                    }
                }
            }
            if !dragging {
                ExerciseNotesView(exerciseID: workoutExercise.exerciseID)
            }
        }
    }
}

// Preview Providers
#Preview("Exercise Top Controls") {
    let preview = PreviewContainer.preview
    ExerciseTopControls(workoutExercise: preview.workout.sortedExercises[0], dragging: .constant(false))
        .padding()
        .modelContainer(preview.container)
        .environment(preview.viewModel)
}
