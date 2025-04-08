import SwiftUI
import SwiftData

struct ExerciseNotesView: View {
    let exerciseID: String
    @Environment(\.modelContext) private var modelContext
    @Environment(\.alertController) private var alertController
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
                    .frame(maxHeight: 100)
                    .scrollContentBackground(.hidden)
                    .focused($focused)
                if exerciseDetail.notes.isEmpty {
                    Text("Add a note")
                        .foregroundColor(Color(uiColor: .placeholderText))
                        .padding(.leading, 10)
                        .allowsHitTesting(false)
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
}

// Preview Providers
#Preview {
    ExerciseNotesView(exerciseID: "1")
}
