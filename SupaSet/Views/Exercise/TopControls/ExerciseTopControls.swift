import SwiftUI
import SwiftData

// First, create a protocol that both exercise types will conform to
protocol ExerciseMenuType: PersistentModel{
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
    @State private var showNotes = false
    let dragging: Bool
    var body: some View {
        VStack{
            HStack(spacing: 5) {
                Text(viewModel.getExerciseName(for: exercise.exerciseID))
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(Color.text)
                Spacer()
                if !dragging{
                    Image(systemName: "note.text")
                        .foregroundColor(Color.text)
                        .font(.system(size: 15, weight: .bold))
                        .onTapGesture {
                            showNotes.toggle()
                        }
                        .padding(5)
                    Button(action: {
                        withAnimation(.snappy) {
                            showMenuOptions.toggle()
                        }
                    }) {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color.text)
                    }
                    .padding(5)
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
            if !dragging && showNotes {
                ExerciseNotesView(exerciseID: exercise.exerciseID)
                    .transition(.slide.combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: showNotes)
    }
}
