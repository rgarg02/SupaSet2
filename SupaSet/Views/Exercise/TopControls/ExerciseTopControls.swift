import SwiftUI

struct ExerciseTopControls: View {
    let workoutExercise: WorkoutExercise
    @Environment(ExerciseViewModel.self) var viewModel
    @State private var showMenuOptions = false
    @State private var showRestTimer = false
    @State private var restTimerTime: TimeInterval = .zero
    @Namespace private var animationNamespace
    
    var body: some View {
        HStack {
            Text(viewModel.getExerciseName(for: workoutExercise.exerciseID))
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.theme.text)
            Spacer()
            Button(action: {
                withAnimation(.snappy) {
                    showMenuOptions.toggle()
                }
            }) {
                Image(systemName: "ellipsis")
                    .foregroundColor(.theme.accent)
                    .matchedGeometryEffect(id: "menuIcon", in: animationNamespace)
            }
            .sheet(isPresented: $showMenuOptions) {
                MenuSheetView(
                    workoutExercise: workoutExercise,
                    showRestTimer: $showRestTimer,
                    restTimerTime: $restTimerTime,
                    showMenuOptions: $showMenuOptions
                )
                .ignoresSafeArea()
                .presentationDetents(
                    [.fraction(0.5)]
                )
                .presentationDragIndicator(.visible)
            }
        }
    }
}

struct MenuSheetView: View {
    let workoutExercise: WorkoutExercise
    @Binding var showRestTimer: Bool
    @Binding var restTimerTime: TimeInterval
    @Binding var showMenuOptions: Bool
    
    var body: some View {
        NavigationView {
            ExerciseMenu(workoutExercise: workoutExercise, showRestTimer: $showRestTimer)
                .foregroundColor(.theme.text)
        }
    }
}

// Preview Providers
#Preview("Exercise Top Controls") {
    let preview = PreviewContainer.preview
    ExerciseTopControls(workoutExercise: preview.workout.sortedExercises[0])
        .padding()
        .modelContainer(preview.container)
        .environment(preview.viewModel)
}
