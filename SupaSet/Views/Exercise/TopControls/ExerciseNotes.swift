import SwiftUI
import SwiftData

struct ExerciseNotesView: View {
    let exerciseID: String
    @Environment(\.modelContext) private var modelContext
    @Query private var exerciseDetails: [ExerciseDetail]
    @FocusState private var focused: Bool
    init(exerciseID: String) {
        self.exerciseID = exerciseID
        _exerciseDetails = Query(filter: #Predicate { $0.exerciseID == exerciseID })
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            if let exerciseDetail = exerciseDetails.first {
                @Bindable var exerciseDetail = exerciseDetail
                TextEditor(text: $exerciseDetail.notes)
                    .frame(minHeight: 50)
                    .focused($focused)
                if exerciseDetail.notes.isEmpty {
                    Text("Add a note")
                        .foregroundColor(Color(uiColor: .placeholderText))
                        .padding(.top, 10)
                        .padding(.leading, 10)
                        .allowsHitTesting(false)
                }
            } else {
                Text("Loading...")
                    .onAppear {
                        loadExerciseDetail()
                    }
            }
        }
        .toolbar {
            if focused{
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        focused = false
                    }
                }
            }
        }
    }

    private func loadExerciseDetail() {
        if let _ = exerciseDetails.first {
            return
        } else {
            let newDetail = ExerciseDetail(exerciseID: exerciseID, notes: "")
            modelContext.insert(newDetail)
            saveExerciseDetail()
        }
    }

    private func saveExerciseDetail() {
        do {
            try modelContext.save()
        } catch {
            print("Failed to save exercise detail: \(error)")
        }
    }
}

// Preview Providers
#Preview {
    ExerciseNotesView(exerciseID: "1")
}