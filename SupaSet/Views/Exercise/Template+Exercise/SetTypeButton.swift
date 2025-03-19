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
                    .foregroundStyle(.blue)
            }
            Button(action: { type = .warmup }) {
                Label("Warm Up", systemImage: "flame")
                    .foregroundStyle(.orange)
            }
            Button(action: { type = .drop }) {
                Label("Drop Set", systemImage: "arrow.down.circle")
                    .foregroundStyle(.purple)
            }
            Button(action: { type = .failure }) {
                Label("Failure", systemImage: "exclamationmark.triangle")
                    .foregroundStyle(.red)
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
    VStack {
        SetRowViewCombined(order: 1, isTemplate: false, weight: .constant(10), reps: .constant(10), isDone: .constant(false), type: .constant(.working))
        SetRowViewCombined(order: 1, isTemplate: false, weight: .constant(10), reps: .constant(10), isDone: .constant(false), type: .constant(.failure))
        SetRowViewCombined(order: 1, isTemplate: false, weight: .constant(10), reps: .constant(10), isDone: .constant(false), type: .constant(.drop))
        SetRowViewCombined(order: 1, isTemplate: false, weight: .constant(10), reps: .constant(10), isDone: .constant(false), type: .constant(.warmup))
        SetRowViewCombined(order: 1, isTemplate: false, weight: .constant(10), reps: .constant(10), isDone: .constant(true), type: .constant(.working))
        SetRowViewCombined(order: 1, isTemplate: false, weight: .constant(10), reps: .constant(10), isDone: .constant(true), type: .constant(.failure))
        SetRowViewCombined(order: 1, isTemplate: false, weight: .constant(10), reps: .constant(10), isDone: .constant(true), type: .constant(.drop))
        SetRowViewCombined(order: 1, isTemplate: false, weight: .constant(10), reps: .constant(10), isDone: .constant(true), type: .constant(.warmup))
    }
    .padding()
}

