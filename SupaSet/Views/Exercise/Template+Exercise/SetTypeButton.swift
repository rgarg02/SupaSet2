import SwiftUI

struct SetTypeButton: View {
    @Binding var type: SetType
    let order: Int
    
    private var displayText: String {
        switch type {
        case .working:
            return String(order+1)
        case .warmup:
            return "W"
        case .drop:
            return "D"
        case .failure:
            return "F"
        }
    }
    
    var body: some View {
        Menu {
            Button(action: { type = .working }) {
                Label("Working Set", systemImage: "figure.strengthtraining.traditional")
                    .foregroundStyle(type.color)
            }
            Button(action: { type = .warmup }) {
                Label("Warm Up", systemImage: "flame")
                    .foregroundStyle(type.color)
            }
            Button(action: { type = .drop }) {
                Label("Drop Set", systemImage: "arrow.down.circle")
                    .foregroundStyle(type.color)
            }
            Button(action: { type = .failure }) {
                Label("Failure", systemImage: "exclamationmark.triangle")
                    .foregroundStyle(type.color)
            }
        } label: {
            Text(displayText)
                .font(.headline)
                .foregroundStyle(type.color)
        }
        .contentTransition(.symbolEffect(.replace))
    }
}

#Preview {
    @Previewable @State var weight: Double = 100
    @Previewable @State var reps: Int = 10
    @Previewable @State var isDone: Bool = false
    @Previewable @State var type: SetType = .working
    VStack{
        VStack{
            SetColumnNamesView(exerciseID: "Exercise", isTemplate: false)
            SetRowViewCombined(
                order: 0,
                isTemplate: false,
                weight: $weight,
                reps: $reps,
                isDone: $isDone,
                type: $type
            )
        }
        VStack{
            SetColumnNamesView(exerciseID: "Exercise", isTemplate: false)
            SetRowViewCombined(
                order: 0,
                isTemplate: false,
                weight: $weight,
                reps: $reps,
                isDone: $isDone,
                type: $type
            )
        }
        .colorScheme(.dark)
    }
    .padding()
    .modelContainer(PreviewContainer.preview.container)
}

