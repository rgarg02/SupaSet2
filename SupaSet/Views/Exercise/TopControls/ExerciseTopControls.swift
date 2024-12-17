import SwiftUI

struct ExerciseTopControls: View {
    let workoutExercise: WorkoutExercise
    @State private var showMenuOptions = false
    @State private var showRestTimer = false
    @State private var restTimerTime: TimeInterval = .zero
    
    var body: some View {
        VStack {
            HStack {
                Text(workoutExercise.exercise.name)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.theme.text)
                Spacer()
                Button(action: {
                    withAnimation(.easeInOut) {
                        showMenuOptions.toggle()
                    }
                }) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.theme.accent)
                }
                .popover(isPresented: $showMenuOptions) {
                    ZStack(alignment: .topTrailing) {
                        ZStack {
                            ExerciseMenu(workoutExercise: workoutExercise, showRestTimer: $showRestTimer)
                            
                            if showRestTimer {
                                CustomRestTimerView(selectedTime: $restTimerTime, showRestTimer: $showRestTimer)
                            }
                        }
                    }
                    .frame(width: 320, height: 400)
                    .background(Color.theme.primary)
                    .presentationCompactAdaptation((.popover))
                    .foregroundStyle(Color.theme.textOpposite)
                }
            }
        }
    }
}



// Preview Providers
#Preview("Exercise Top Controls") {
    let preview = PreviewContainer.preview
    ExerciseTopControls(workoutExercise: preview.workout.sortedExercises[0])
        .padding()
        .modelContainer(preview.container)
}
